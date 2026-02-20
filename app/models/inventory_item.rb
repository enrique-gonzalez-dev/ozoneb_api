class InventoryItem < ApplicationRecord
  # InventoryItem is the STI base class. Do not mark it as abstract so
  # subclasses (Product, ProductBase, Container, Label, RawMaterial)
  # will use the `inventory_items` table.
  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: { case_sensitive: false }
  validates :unit, presence: true

  # Normalize identifier to avoid accidental duplicates caused by
  # leading/trailing whitespace. We keep original case so the user
  # sees what they typed, while DB uniqueness is enforced case-
  # insensitively by an index on lower(identifier).
  before_validation :normalize_identifier

  # Callback para crear registros en inventory_item_branches para todas las sucursales
  after_create :create_inventory_item_branches_for_all_branches

  # Relación con branches a través de inventory_item_branches
  has_many :inventory_item_branches, dependent: :destroy
  has_many :branches, through: :inventory_item_branches

  # Polymorphic item components relations
  # An InventoryItem (owner) can have many item_components (its components)
  has_many :item_components, as: :owner, dependent: :destroy, inverse_of: :owner
  has_many :components, through: :item_components, source: :component, source_type: 'InventoryItem'

  # As a component used by other owners
  # When an InventoryItem that is used as a component is removed,
  # nullifying the polymorphic `component` would violate DB NOT NULL
  # constraints (component_type/component_id). Use `delete_all` so
  # the join rows are removed at the DB level without trying to set
  # them to NULL.
  has_many :component_of, as: :component, class_name: 'ItemComponent', dependent: :delete_all, inverse_of: :component
  has_many :owners, through: :component_of, source: :owner

  # Replace the current components of this item with the provided list.
  # Expects an array of hashes: [{ id: uuid, quantity: 4 }, ...]
  # Raises ActiveRecord::RecordInvalid with errors attached to self when validation fails.
  def replace_components(components_param)
    comps = Array(components_param).map do |c|
      { id: (c[:id] || c['id']), quantity: (c[:quantity] || c['quantity'] || 0) }
    end

    ids = comps.map { |c| c[:id] }.compact
    return if ids.empty?

    found = InventoryItem.where(id: ids).index_by(&:id)

    missing = ids - found.keys
    if missing.any?
      errors.add(:components, "missing component ids: #{missing.join(', ')}")
      raise ActiveRecord::RecordInvalid.new(self)
    end

    transaction do
      # remove existing relations and create new ones
      item_components.destroy_all
      comps.each do |c|
        component = found[c[:id]]
        next unless component
        item_components.create!(component: component, quantity: c[:quantity])
      end
    end
  end

  private

  def normalize_identifier
    self.identifier = identifier.to_s.strip.presence
  end

  def create_inventory_item_branches_for_all_branches
    Branch.find_each do |branch|
      inventory_item_branches.create!(
        branch: branch,
        stock: 0,
        safe_stock: 0,
        time_to_warning: 0,
        entry: 0,
        output: 0
      )
    end
  end
end

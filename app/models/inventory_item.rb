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

  private

  def normalize_identifier
    self.identifier = identifier.to_s.strip.presence
  end
end

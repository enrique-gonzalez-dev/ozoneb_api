# frozen_string_literal: true

class InventoryTransaction < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :branch
  has_many :inventory_transaction_items, dependent: :destroy
  has_many :inventory_items, through: :inventory_transaction_items

  # Temporary attribute for branch transfers
  attr_accessor :destination_branch_id

  # Enums
  enum :transaction_type, { entry: 0, exit: 1 }

  enum :transaction_subtype, {
    # Entry subtypes
    production: 0,
    transfer_from_branch: 1,
    return_entry: 2,

    # Exit subtypes
    return_exit: 3,
    waste: 4
  }

  # Validations
  validates :transaction_type, presence: true
  validates :transaction_subtype, presence: true
  validate :validate_subtype_matches_type
  validate :validate_component_availability, on: :create, if: :production_entry?
  validate :validate_destination_branch_for_transfer, on: :create, if: :transfer_entry?
  validates :note, length: { maximum: 1000 }

  # Nested attributes
  accepts_nested_attributes_for :inventory_transaction_items, allow_destroy: true

  # Callbacks
  after_commit :deduct_components_from_inventory, on: :create, if: :production_entry?
  after_commit :process_branch_transfer, on: :create, if: :transfer_entry?
  after_commit :process_return_entry, on: :create, if: :return_entry_type?

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_branch, ->(branch_id) { where(branch_id: branch_id) }

  private

  def production_entry?
    entry? && production?
  end

  def transfer_entry?
    entry? && transfer_from_branch?
  end

  def return_entry_type?
    entry? && return_entry?
  end

  def deduct_components_from_inventory
    return unless production_entry?

    inventory_transaction_items.includes(inventory_item: [:item_components, :components]).each do |transaction_item|
      product = transaction_item.inventory_item
      produced_quantity = transaction_item.quantity

      # Solo procesar si el producto tiene componentes
      next unless product.item_components.any?

      product.item_components.each do |item_component|
        component = item_component.component
        required_quantity_per_unit = item_component.quantity
        total_required_quantity = required_quantity_per_unit * produced_quantity

        # Buscar el registro de inventario del componente en la sucursal
        inventory_item_branch = InventoryItemBranch.find_by(
          inventory_item_id: component.id,
          branch_id: branch_id
        )

        if inventory_item_branch.nil?
          Rails.logger.error "InventoryItemBranch not found for component #{component.id} in branch #{branch_id}"
          next
        end

        # Convertir a entero (redondeando hacia abajo) ya que stock/output son integer
        total_required_quantity_int = total_required_quantity.to_i

        # Validar que hay suficiente stock
        if inventory_item_branch.stock < total_required_quantity_int
          Rails.logger.warn "Insufficient stock for component #{component.name} (#{component.identifier}). " \
                           "Required: #{total_required_quantity_int}, Available: #{inventory_item_branch.stock}"
          # Continuar pero loggear el problema
        end

        # Descontar del stock y registrar la salida
        new_stock = [inventory_item_branch.stock - total_required_quantity_int, 0].max
        new_output = inventory_item_branch.output + total_required_quantity_int

        inventory_item_branch.update!(
          stock: new_stock,
          output: new_output
        )

        Rails.logger.info "Deducted #{total_required_quantity_int} units of component #{component.name} " \
                         "(#{component.identifier}) from branch #{branch.name} for production transaction #{id}"
      end
    end
  rescue StandardError => e
    Rails.logger.error "Error deducting components for transaction #{id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # No re-lanzamos el error para evitar fallar la transacción ya commitada
  end

  def process_branch_transfer
    return unless transfer_entry?
    return unless destination_branch_id.present?

    inventory_transaction_items.includes(:inventory_item).each do |transaction_item|
      item = transaction_item.inventory_item
      quantity = transaction_item.quantity.to_i  # Convertir a entero

      # Descontar de la sucursal origen (branch_id)
      origin_inventory = InventoryItemBranch.find_by(
        inventory_item_id: item.id,
        branch_id: branch_id
      )

      if origin_inventory.nil?
        Rails.logger.error "InventoryItemBranch not found for item #{item.id} in origin branch #{branch_id}"
        next
      end

      # Validar stock disponible en origen
      if origin_inventory.stock < quantity
        Rails.logger.warn "Insufficient stock in origin branch for item #{item.name} (#{item.identifier}). " \
                         "Required: #{quantity}, Available: #{origin_inventory.stock}"
      end

      # Descontar del origen
      new_origin_stock = [origin_inventory.stock - quantity, 0].max
      new_origin_output = origin_inventory.output + quantity

      origin_inventory.update!(
        stock: new_origin_stock,
        output: new_origin_output
      )

      Rails.logger.info "Deducted #{quantity} units of #{item.name} (#{item.identifier}) from branch #{branch.name}"

      # Aumentar en la sucursal destino (destination_branch_id)
      destination_inventory = InventoryItemBranch.find_by(
        inventory_item_id: item.id,
        branch_id: destination_branch_id
      )

      if destination_inventory.nil?
        Rails.logger.error "InventoryItemBranch not found for item #{item.id} in destination branch #{destination_branch_id}"
        next
      end

      # Aumentar en el destino
      new_destination_stock = destination_inventory.stock + quantity
      new_destination_entry = destination_inventory.entry + quantity

      destination_inventory.update!(
        stock: new_destination_stock,
        entry: new_destination_entry
      )

      destination_branch = Branch.find_by(id: destination_branch_id)
      Rails.logger.info "Added #{quantity} units of #{item.name} (#{item.identifier}) to branch #{destination_branch&.name || destination_branch_id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error processing branch transfer for transaction #{id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def process_return_entry
    return unless return_entry_type?

    inventory_transaction_items.includes(:inventory_item).each do |transaction_item|
      item = transaction_item.inventory_item
      quantity = transaction_item.quantity.to_i  # Convertir a entero

      # Buscar el registro de inventario del item en la sucursal
      inventory_item_branch = InventoryItemBranch.find_by(
        inventory_item_id: item.id,
        branch_id: branch_id
      )

      if inventory_item_branch.nil?
        Rails.logger.error "InventoryItemBranch not found for item #{item.id} in branch #{branch_id}"
        next
      end

      # Aumentar el stock y registrar la entrada
      new_stock = inventory_item_branch.stock + quantity
      new_entry = inventory_item_branch.entry + quantity

      inventory_item_branch.update!(
        stock: new_stock,
        entry: new_entry
      )

      Rails.logger.info "Added #{quantity} units of #{item.name} (#{item.identifier}) " \
                       "to branch #{branch.name} as return entry for transaction #{id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error processing return entry for transaction #{id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def validate_subtype_matches_type
    return if transaction_type.blank? || transaction_subtype.blank?

    entry_subtypes = %w[production transfer_from_branch return_entry]
    exit_subtypes = %w[return_exit waste]

    if entry? && !entry_subtypes.include?(transaction_subtype)
      errors.add(:transaction_subtype, 'must be a valid entry subtype (production, transfer_from_branch, or return_entry)')
    elsif exit? && !exit_subtypes.include?(transaction_subtype)
      errors.add(:transaction_subtype, 'must be a valid exit subtype (return_exit or waste)')
    end
  end

  def validate_component_availability
    return unless production_entry?
    return if branch_id.blank?

    # Acumular los componentes requeridos por todos los productos a producir
    required_components = Hash.new(0)

    inventory_transaction_items.each do |transaction_item|
      product = transaction_item.inventory_item
      next unless product

      # Cargar los componentes del producto
      components = product.item_components.includes(:component)
      next if components.empty?

      produced_quantity = transaction_item.quantity.to_f

      components.each do |item_component|
        component = item_component.component
        next unless component

        component_id = component.id
        required_quantity_per_unit = item_component.quantity.to_f
        total_required = required_quantity_per_unit * produced_quantity

        required_components[component_id] += total_required
      end
    end

    # Validar que hay suficiente stock de cada componente en la sucursal
    required_components.each do |component_id, total_required|
      component = InventoryItem.find_by(id: component_id)
      next unless component

      inventory_item_branch = InventoryItemBranch.find_by(
        inventory_item_id: component_id,
        branch_id: branch_id
      )

      if inventory_item_branch.nil?
        errors.add(:base, "Component #{component.name} (#{component.identifier}) not found in branch inventory")
        next
      end

      available_stock = inventory_item_branch.stock.to_f

      if available_stock < total_required
        errors.add(
          :base,
          "Insufficient stock for component #{component.name} (#{component.identifier}). " \
          "Required: #{total_required}, Available: #{available_stock}"
        )
      end
    end
  end

  def validate_destination_branch_for_transfer
    return unless transfer_entry?

    if destination_branch_id.blank?
      errors.add(:destination_branch_id, 'is required for branch transfers')
      return
    end

    # Validar que la sucursal destino existe
    unless Branch.exists?(id: destination_branch_id)
      errors.add(:destination_branch_id, 'branch does not exist')
      return
    end

    # Validar que origen y destino sean diferentes
    if destination_branch_id == branch_id
      errors.add(:destination_branch_id, 'must be different from origin branch')
      return
    end

    # Validar que hay suficiente stock en la sucursal origen
    inventory_transaction_items.each do |transaction_item|
      item = transaction_item.inventory_item
      next unless item

      origin_inventory = InventoryItemBranch.find_by(
        inventory_item_id: item.id,
        branch_id: branch_id
      )

      if origin_inventory.nil?
        errors.add(:base, "Item #{item.name} (#{item.identifier}) not found in origin branch inventory")
        next
      end

      if origin_inventory.stock < transaction_item.quantity
        errors.add(
          :base,
          "Insufficient stock in origin branch for item #{item.name} (#{item.identifier}). " \
          "Required: #{transaction_item.quantity}, Available: #{origin_inventory.stock}"
        )
      end
    end
  end
end

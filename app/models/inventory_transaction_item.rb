# frozen_string_literal: true

class InventoryTransactionItem < ApplicationRecord
  # Associations
  belongs_to :inventory_transaction
  belongs_to :inventory_item

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :inventory_item_id, uniqueness: {
    scope: :inventory_transaction_id,
    message: 'can only be added once per transaction'
  }

  # Callbacks
  before_save :validate_inventory_availability, if: :exit_transaction?

  private

  def exit_transaction?
    inventory_transaction&.exit?
  end

  def validate_inventory_availability
    return unless inventory_item

    # For exit transactions, ensure there's enough inventory
    if inventory_item.quantity && quantity > inventory_item.quantity
      errors.add(:quantity, "cannot exceed available inventory (#{inventory_item.quantity} available)")
      throw(:abort)
    end
  end
end

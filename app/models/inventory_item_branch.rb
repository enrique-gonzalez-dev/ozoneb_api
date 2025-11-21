class InventoryItemBranch < ApplicationRecord
  belongs_to :inventory_item
  belongs_to :branch

  validates :inventory_item_id, presence: true
  validates :branch_id, presence: true
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :safe_stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :time_to_warning, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :entry, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :output, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Asegurar que la combinación de inventory_item_id y branch_id sea única
  validates :inventory_item_id, uniqueness: { scope: :branch_id }
end

class Branch < ApplicationRecord
  has_and_belongs_to_many :users

  # Relación con inventory_items a través de inventory_item_branches
  has_many :inventory_item_branches, dependent: :destroy
  has_many :inventory_items, through: :inventory_item_branches

  validates :name, presence: true
  validates :branch_type, presence: true

  enum :branch_type, { production: 0, store_only: 1 }
end

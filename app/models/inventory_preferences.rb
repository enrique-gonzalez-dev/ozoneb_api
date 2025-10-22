class InventoryPreferences < ApplicationRecord
  belongs_to :user

  validates :low_stock_alerts, inclusion: { in: [true, false] }
  validates :low_stock_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :email_notifications, inclusion: { in: [true, false] }
  validates :branches_to_show, presence: true
  validates :default_items_per_page, numericality: { only_integer: true, greater_than: 0 }
end

class Api::V1::InventoryPreferencesSerializer < ActiveModel::Serializer
  attributes :id, :display, :notifications, :branches

  def display
    {
      low_stock_alerts: object.low_stock_alerts,
      low_stock_threshold: object.low_stock_threshold,
      default_items_per_page: object.default_items_per_page
    }
  end

  def notifications
    {
      email_notifications: object.email_notifications
    }
  end

  def branches
    ids = object.branches_to_show.map(&:to_s)
    branches = if object.user.admin?
      Branch.all
    else
      object.user.branches
    end

    branches.map do |branch|
      {
        id: branch.id,
        name: branch.name,
        active: ids.include?(branch.id.to_s)
      }
    end
  end
end

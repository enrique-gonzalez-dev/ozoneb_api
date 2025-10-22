class CreateInventoryPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_preferences, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.boolean :low_stock_alerts, default: true, null: false
      t.integer :low_stock_threshold, default: 10, null: false
      t.boolean :email_notifications, default: true, null: false
      t.string :branches_to_show, array: true, default: ['all'], null: false
      t.integer :default_items_per_page, default: 50, null: false

      t.timestamps
    end
  end
end

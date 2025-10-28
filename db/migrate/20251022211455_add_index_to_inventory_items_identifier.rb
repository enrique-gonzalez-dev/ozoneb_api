class AddIndexToInventoryItemsIdentifier < ActiveRecord::Migration[8.0]
  def change
    # Case-insensitive unique index on identifier
    add_index :inventory_items, "lower(identifier)", unique: true, name: "index_inventory_items_on_lower_identifier"
    # fallback index on identifier (keeps compatibility)
    add_index :inventory_items, :identifier
  end
end

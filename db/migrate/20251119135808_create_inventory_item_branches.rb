class CreateInventoryItemBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_item_branches, id: :uuid do |t|
      t.references :inventory_item, null: false, foreign_key: true, type: :uuid
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.integer :stock, default: 0, null: false
      t.integer :safe_stock, default: 0, null: false
      t.integer :time_to_warning, default: 0, null: false
      t.integer :entry, default: 0, null: false
      t.integer :output, default: 0, null: false

      t.timestamps
    end

    add_index :inventory_item_branches, [:inventory_item_id, :branch_id], unique: true, name: 'index_inventory_item_branches_on_item_and_branch'
  end
end

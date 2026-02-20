class CreateInventoryTransactionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_transaction_items, id: :uuid do |t|
      t.references :inventory_transaction, null: false, foreign_key: true, type: :uuid
      t.references :inventory_item, null: false, foreign_key: true, type: :uuid
      t.decimal :quantity, precision: 10, scale: 2, null: false

      t.timestamps
    end
    
    add_index :inventory_transaction_items, [:inventory_transaction_id, :inventory_item_id], 
              name: 'index_inv_trans_items_on_trans_and_item', unique: true
  end
end

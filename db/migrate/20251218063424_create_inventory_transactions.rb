class CreateInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_transactions, id: :uuid do |t|
      t.integer :transaction_type
      t.integer :transaction_subtype
      t.text :note
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

class AddBranchToInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    add_reference :inventory_transactions, :branch, null: false, foreign_key: true, type: :uuid
  end
end

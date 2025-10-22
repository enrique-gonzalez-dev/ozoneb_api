class CreateJoinTableUsersBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :branches_users, id: false do |t|
      t.uuid :user_id, null: false
      t.uuid :branch_id, null: false
    end
    add_index :branches_users, [:user_id, :branch_id], unique: true
    add_index :branches_users, :branch_id
  end
end

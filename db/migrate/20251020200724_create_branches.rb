class CreateBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :branches, id: :uuid do |t|
      t.string :name
      t.integer :branch_type

      t.timestamps
    end
  end
end

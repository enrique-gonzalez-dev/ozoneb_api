class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items, id: :uuid do |t|
      t.string :name
      t.string :identifier
      t.text :comment
      t.string :unit
      t.string :type

      t.timestamps
    end
  end
end

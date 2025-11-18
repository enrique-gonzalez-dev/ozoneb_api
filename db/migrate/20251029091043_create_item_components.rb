class CreateItemComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :item_components, id: :uuid do |t|
      # owner is polymorphic so Product, ProductBase or any other model can own components
      t.references :owner, polymorphic: true, null: false, type: :uuid
      t.references :component, polymorphic: true, null: false, type: :uuid
      t.decimal :quantity, precision: 12, scale: 4, default: 0.0, null: false
      t.string :unit

      t.timestamps
    end

    add_index :item_components, [:owner_type, :owner_id]
    add_index :item_components, [:component_type, :component_id]
  end
end

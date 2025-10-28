class CreateCategoriesProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :categories_products, id: :uuid do |t|
      t.uuid :category_id
      t.uuid :product_id

      t.timestamps
    end
  end
end

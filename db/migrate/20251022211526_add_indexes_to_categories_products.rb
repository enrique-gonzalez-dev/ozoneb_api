class AddIndexesToCategoriesProducts < ActiveRecord::Migration[8.0]
  def change
    add_index :categories_products, :category_id
    add_index :categories_products, :product_id
    add_index :categories_products, [:category_id, :product_id], unique: true, name: "index_categories_products_on_category_and_product"
  end
end

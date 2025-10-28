class Product < InventoryItem
  has_and_belongs_to_many :categories,
    class_name: 'Category',
    join_table: 'categories_products',
    association_foreign_key: 'category_id',
    foreign_key: 'product_id'
end

class Product < InventoryItem
  has_and_belongs_to_many :categories,
    class_name: 'Category',
    join_table: 'categories_products',
    association_foreign_key: 'category_id',
    foreign_key: 'product_id'

  # Components owned by this product (labels, containers, product_bases, raw_materials, etc.)
  has_many :item_components, as: :owner, dependent: :destroy

  has_many :labels, through: :item_components, source: :component, source_type: 'Label'
  has_many :containers, through: :item_components, source: :component, source_type: 'Container'
  has_many :product_bases, through: :item_components, source: :component, source_type: 'ProductBase'
  has_many :raw_materials, through: :item_components, source: :component, source_type: 'RawMaterial'
  # Allow Products to contain other Products as components
  has_many :products, through: :item_components, source: :component, source_type: 'Product'
end

class ProductBase < InventoryItem
  # Allow a ProductBase to also own components (itself can be composed of raw materials, labels, containers, etc.)
  has_many :item_components, as: :owner, dependent: :destroy

  has_many :labels, through: :item_components, source: :component, source_type: 'Label'
  has_many :containers, through: :item_components, source: :component, source_type: 'Container'
  has_many :product_bases, through: :item_components, source: :component, source_type: 'ProductBase'
  has_many :raw_materials, through: :item_components, source: :component, source_type: 'RawMaterial'
  has_many :products, through: :item_components, source: :component, source_type: 'Product'
end

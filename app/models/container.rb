class Container < InventoryItem
  has_many :item_components, as: :component, dependent: :nullify
  # Also allow a Container to own components itself
  has_many :owned_item_components, as: :owner, class_name: 'ItemComponent', dependent: :destroy

  has_many :labels, through: :owned_item_components, source: :component, source_type: 'Label'
  has_many :containers, through: :owned_item_components, source: :component, source_type: 'Container'
  has_many :product_bases, through: :owned_item_components, source: :component, source_type: 'ProductBase'
  has_many :raw_materials, through: :owned_item_components, source: :component, source_type: 'RawMaterial'
  has_many :products, through: :owned_item_components, source: :component, source_type: 'Product'
end

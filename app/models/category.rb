class Category < ApplicationRecord
  has_and_belongs_to_many :products,
    class_name: 'Product',
    join_table: 'categories_products',
    association_foreign_key: 'product_id',
    foreign_key: 'category_id'

  validates :name, presence: true, uniqueness: true
end

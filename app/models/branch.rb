class Branch < ApplicationRecord
  has_and_belongs_to_many :users

  validates :name, presence: true
  validates :branch_type, presence: true

  enum :branch_type, { production: 0, store_only: 1 }
end

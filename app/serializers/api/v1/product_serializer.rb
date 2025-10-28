class Api::V1::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :comment, :unit, :type, :categories

  def categories
    object.categories.map do |category|
      {
        id: category.id,
        name: category.name
      }
    end
  end
end

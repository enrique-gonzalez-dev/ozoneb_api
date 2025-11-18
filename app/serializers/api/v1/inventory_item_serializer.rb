class Api::V1::InventoryItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :unit, :type
end

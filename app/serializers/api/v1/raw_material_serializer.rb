class Api::V1::RawMaterialSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :comment, :unit, :type
end

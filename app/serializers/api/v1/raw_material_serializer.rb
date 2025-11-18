class Api::V1::RawMaterialSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :unit, :type, :comment
end

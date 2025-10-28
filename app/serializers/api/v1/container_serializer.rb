class Api::V1::ContainerSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :comment, :unit, :type
end

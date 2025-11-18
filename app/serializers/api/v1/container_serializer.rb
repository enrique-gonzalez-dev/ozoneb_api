class Api::V1::ContainerSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :unit, :type, :comment
end

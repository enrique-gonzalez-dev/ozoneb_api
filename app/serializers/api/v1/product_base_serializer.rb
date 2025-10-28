class Api::V1::ProductBaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :comment, :unit, :type
end

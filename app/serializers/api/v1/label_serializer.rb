class Api::V1::LabelSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :comment, :unit, :type
end

class Api::V1::LabelSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :unit, :type, :comment
end

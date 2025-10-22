class Api::V1::BranchSerializer < ActiveModel::Serializer
  attributes :id, :name, :branch_type
end

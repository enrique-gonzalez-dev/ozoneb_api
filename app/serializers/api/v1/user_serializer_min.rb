class Api::V1::UserSerializerMin < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :last_name, :role, :email, :status, :branches

  def branches
    object.branches.map do |branch|
      {
        id: branch.id,
        name: branch.name
      }
    end
  end
end

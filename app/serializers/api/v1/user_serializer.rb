class Api::V1::UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :last_name, :role, :email, :status, :avatar_url, :branches

  def avatar_url
    return nil unless object.avatar.attached?

    request = instance_options[:request]
    begin
      if request
        url_options = {
          host: request.host,
          port: request.port,
          protocol: request.protocol.chomp('://')
        }
        rails_blob_url(object.avatar, url_options.merge(only_path: false))
      else
        rails_blob_url(object.avatar, only_path: false)
      end
    rescue => e
      Rails.logger.error "Error generating avatar URL: #{e.message}"
      begin
        rails_blob_path(object.avatar)
      rescue => fallback_error
        Rails.logger.error "Error generating avatar path: #{fallback_error.message}"
        nil
      end
    end
  end

  def branches
    object.branches.map do |branch|
      {
        id: branch.id,
        name: branch.name
      }
    end
  end
end

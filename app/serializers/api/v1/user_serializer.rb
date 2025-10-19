class Api::V1::UserSerializer
  include Rails.application.routes.url_helpers

  def initialize(user, request: nil)
    @user = user
    @request = request
  end

  def as_json
    {
      id: @user.id,
      name: @user.name,
      last_name: @user.last_name,
      role: @user.role,
      email: @user.email,
      status: @user.status,
      avatar_url: avatar_url
    }
  end

  private

  def avatar_url
    return nil unless @user.avatar.attached?

    begin
      # Try to generate the URL using Rails blob URL helpers
      if @request
        # Use request context for full URL
        url_options = {
          host: @request.host,
          port: @request.port,
          protocol: @request.protocol.chomp('://')
        }

        rails_blob_url(@user.avatar, url_options.merge(only_path: false))
      else
        # Fallback: generate with default configuration
        rails_blob_url(@user.avatar, only_path: false)
      end
    rescue => e
      Rails.logger.error "Error generating avatar URL: #{e.message}"

      # Final fallback: return relative path
      begin
        rails_blob_path(@user.avatar)
      rescue => fallback_error
        Rails.logger.error "Error generating avatar path: #{fallback_error.message}"
        nil
      end
    end
  end
end

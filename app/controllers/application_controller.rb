class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_request
  attr_reader :current_user

  # Handle parameter parsing errors gracefully
  rescue_from ActionDispatch::Http::Parameters::ParseError do |exception|
    Rails.logger.error "Parameter parsing error: #{exception.message}"
    render json: {
      status: {
        message: 'Invalid request format. Please ensure you are sending the correct content type.'
      }
    }, status: :bad_request
  end

  private

  def authenticate_request
    auth_result = AuthorizeApiRequest.call(request.headers)
    @current_user = auth_result[:result]
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  def authenticate_user!
    authenticate_request
  end
end

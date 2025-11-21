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

  def check_admin_or_supervisor
    unless current_user&.can_create_users?
      render json: {
        status: { message: "You don't have permission to perform this action." }
      }, status: :forbidden
    end
  end

  def check_admin
    unless current_user&.admin?
      render json: {
        status: { message: "You don't have permission to perform this action. Only admins can delete users." }
      }, status: :forbidden
    end
  end

  # Obtiene los IDs de branches que el usuario tiene configurados en sus inventory_preferences
  def user_branches_to_show
    return [] unless current_user&.inventory_preferences
    current_user.inventory_preferences.branches_to_show || []
  end
end

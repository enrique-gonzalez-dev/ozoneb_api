class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

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

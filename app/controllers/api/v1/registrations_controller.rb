class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :authenticate_user!, only: [ :create ]
  before_action :check_admin_or_supervisor, only: [ :create ]

  def create
    build_resource(sign_up_params)

    if resource.save
      render json: {
        status: { code: 200, message: 'User created successfully.' },
        data: Api::V1::UserSerializer.new(resource).as_json
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation, :role)
  end

  def check_admin_or_supervisor
    unless current_user&.can_create_users?
      render json: {
        status: { message: "You don't have permission to create users." }
      }, status: :forbidden
    end
  end

  def respond_with(resource, _opts = {})
    if request.method == 'POST' && resource.persisted?
      render json: {
        status: { code: 200, message: 'User created successfully.' },
        data: Api::V1::UserSerializer.new(resource).as_json
      }, status: :ok
    elsif request.method == 'DELETE'
      render json: {
        status: { code: 200, message: 'Account deleted successfully.' }
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end

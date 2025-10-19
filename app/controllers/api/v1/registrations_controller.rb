class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :authenticate_user!
  before_action :check_admin_or_supervisor

  def new
    render json: { status: { message: 'El registro está deshabilitado. Solo los administradores o supervisores pueden crear usuarios.' } }, status: :forbidden
  end


  def create
    user_params = sign_up_params
    # Lógica de asignación de rol según el rol del usuario actual
    if current_user.admin?
      # Admin puede asignar cualquier rol
      assigned_role = params[:user][:role] if params[:user][:role].present?
      user_params[:role] = assigned_role if assigned_role.present? && User.roles.keys.include?(assigned_role)
    elsif current_user.supervisor?
      # Supervisor solo puede crear usuarios operativos
      user_params[:role] = 'operation'
    end

    build_resource(user_params)

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
    if current_user&.admin?
      # Solo los admins pueden asignar el rol
      params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation, :role)
    else
      # Supervisores y otros no pueden asignar el rol
      params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation)
    end
  end

  def check_admin_or_supervisor
    unless current_user&.can_create_users?
      render json: {
        status: { message: 'No tienes permiso para crear usuarios.' }
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

class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :update, :destroy ]
  before_action :check_admin_or_supervisor, only: [ :index, :create, :destroy ]

  def index
    @users = User.all
    render json: {
      status: { code: 200, message: 'Users retrieved successfully.' },
      data: @users.map { |user| Api::V1::UserSerializer.new(user).as_json }
    }, status: :ok
  end

  def show
    render json: {
      status: { code: 200, message: 'User retrieved successfully.' },
      data: Api::V1::UserSerializer.new(@user).as_json
    }, status: :ok
  end

  def create
    @user = User.new(user_params_for_creation)

    if @user.save
      render json: {
        status: { code: 200, message: 'User created successfully.' },
        data: Api::V1::UserSerializer.new(@user).as_json
      }, status: :created
    else
      render json: {
        status: { message: "User couldn't be created. #{@user.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

  def update
    if @user == current_user || current_user.can_create_users?
      if @user.update(user_params)
        render json: {
          status: { code: 200, message: 'User updated successfully.' },
          data: Api::V1::UserSerializer.new(@user).as_json
        }, status: :ok
      else
        render json: {
          status: { message: "User couldn't be updated. #{@user.errors.full_messages.to_sentence}" }
        }, status: :unprocessable_entity
      end
    else
      render json: {
        status: { message: "You don't have permission to update this user." }
      }, status: :forbidden
    end
  end

  def destroy
    if @user.destroy
      render json: {
        status: { code: 200, message: 'User deleted successfully.' }
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be deleted." }
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { message: 'User not found.' }
    }, status: :not_found
  end

  def user_params
    if current_user.can_create_users?
      params.require(:user).permit(:name, :last_name, :email, :role)
    else
      params.require(:user).permit(:name, :last_name, :email)
    end
  end

  def user_params_for_creation
    params.require(:user).permit(:name, :last_name, :email, :role, :password, :password_confirmation)
  end

  def check_admin_or_supervisor
    unless current_user&.can_create_users?
      render json: {
        status: { message: "You don't have permission to perform this action." }
      }, status: :forbidden
    end
  end
end

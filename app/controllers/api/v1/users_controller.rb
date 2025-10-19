class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :update, :destroy, :update_avatar ]
  before_action :check_admin_or_supervisor, only: [ :index, :create, :destroy ]

  def index
    @users = User.search(search_param)
    @users = apply_status_filter(@users)
    @users = apply_sorting(@users)
    @users = @users.page(page_param).per(per_page_param)

    render json: {
      status: { code: 200, message: 'Users retrieved successfully.' },
      data: @users.map { |user| Api::V1::UserSerializer.new(user, request: request).as_json },
      pagination: pagination(@users)
    }, status: :ok
  end

  def show
    render json: {
      status: { code: 200, message: 'User retrieved successfully.' },
      data: Api::V1::UserSerializer.new(@user, request: request).as_json
    }, status: :ok
  end

  def create
    # Generate temporary password if not provided
    temporary_password = user_params_for_creation[:password].present? ?
                        user_params_for_creation[:password] :
                        User.generate_temporary_password

    @user = User.new(user_params_for_creation.except(:password, :password_confirmation))
    @user.password = temporary_password
    @user.password_confirmation = temporary_password

    if @user.save
      # Send invitation email with temporary password
      UserMailer.invitation_instructions(@user, temporary_password).deliver_now

      render json: {
        status: { code: 200, message: 'User created successfully. Invitation email sent.' },
        data: Api::V1::UserSerializer.new(@user, request: request).as_json
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
          data: Api::V1::UserSerializer.new(@user, request: request).as_json
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

  def update_password
    if current_user.valid_password?(password_params[:current_password])
      if current_user.update(password: password_params[:password], password_confirmation: password_params[:password_confirmation])
        render json: {
          status: { code: 200, message: 'Password updated successfully.' }
        }, status: :ok
      else
        render json: {
          status: { message: "Password couldn't be updated. #{current_user.errors.full_messages.to_sentence}" }
        }, status: :unprocessable_entity
      end
    else
      render json: {
        status: { message: 'Current password is incorrect.' }
      }, status: :unprocessable_entity
    end
  end

  def update_avatar
    # Verificar permisos: solo el mismo usuario o admin/supervisor pueden actualizar el avatar
    unless @user == current_user || current_user.can_create_users?
      render json: {
        status: { message: "You don't have permission to update this user's avatar." }
      }, status: :forbidden
      return
    end

    # Verificar que el parámetro avatar esté presente
    unless params[:avatar].present?
      render json: {
        status: { message: 'Avatar file is required.' }
      }, status: :bad_request
      return
    end

    avatar_file = params[:avatar]

    # Validar que es un archivo válido (ActionDispatch::Http::UploadedFile)
    unless avatar_file.is_a?(ActionDispatch::Http::UploadedFile)
      render json: {
        status: { message: 'Invalid file format. Please provide a valid file.' }
      }, status: :bad_request
      return
    end

    # Validar el tipo de archivo
    allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
    unless allowed_types.include?(avatar_file.content_type)
      render json: {
        status: { message: 'Invalid file type. Only JPEG, PNG and GIF are allowed.' }
      }, status: :bad_request
      return
    end

    # Validar el tamaño del archivo (5MB máximo)
    max_size = 5.megabytes
    if avatar_file.size > max_size
      render json: {
        status: { message: 'File size too large. Maximum size is 5MB.' }
      }, status: :bad_request
      return
    end

    # Validar que el archivo no esté vacío
    if avatar_file.size == 0
      render json: {
        status: { message: 'File cannot be empty.' }
      }, status: :bad_request
      return
    end

    begin
      # Purge existing avatar if present
      @user.avatar.purge if @user.avatar.attached?

      # Attach new avatar
      @user.avatar.attach(avatar_file)

      if @user.save
        # Wait a moment for the attachment to be fully processed
        @user.reload

        begin
          serialized_user = Api::V1::UserSerializer.new(@user, request: request).as_json
          render json: {
            status: { code: 200, message: 'Avatar updated successfully.' },
            data: serialized_user
          }, status: :ok
        rescue => serializer_error
          Rails.logger.error "Serializer error after avatar upload: #{serializer_error.message}"
          # Return basic response without avatar URL if serialization fails
          render json: {
            status: { code: 200, message: 'Avatar updated successfully.' },
            data: {
              id: @user.id,
              name: @user.name,
              last_name: @user.last_name,
              role: @user.role,
              email: @user.email,
              status: @user.status,
              avatar_url: 'Avatar uploaded but URL generation pending. Please refresh to see the avatar.'
            }
          }, status: :ok
        end
      else
        render json: {
          status: { message: "Avatar couldn't be updated. #{@user.errors.full_messages.to_sentence}" }
        }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Avatar upload error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      render json: {
        status: { message: 'An error occurred while uploading the avatar. Please try again.' }
      }, status: :internal_server_error
    end
  end

  def me
    render json: {
      status: { code: 200, message: 'Current user retrieved successfully.' },
      data: Api::V1::UserSerializer.new(current_user, request: request).as_json
    }, status: :ok
  end

  private

  def pagination(users)
    {
      current_page: users.current_page,
      total_pages: users.total_pages,
      total_count: users.total_count,
      per_page: users.limit_value,
      next_page: users.next_page,
      prev_page: users.prev_page
    }
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { message: 'User not found.' }
    }, status: :not_found
  end

  def user_params
    if current_user.admin?
      params.require(:user).permit(:name, :last_name, :email, :role, :status, :avatar)
    elsif current_user.can_create_users?
      params.require(:user).permit(:name, :last_name, :email, :status, :avatar)
    else
      params.require(:user).permit(:name, :last_name, :email, :avatar)
    end
  end

  def user_params_for_creation
    if current_user.admin?
      params.require(:user).permit(:name, :last_name, :email, :role, :password, :password_confirmation, :avatar)
    else
      params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation, :avatar)
    end
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def check_admin_or_supervisor
    unless current_user&.can_create_users?
      render json: {
        status: { message: "You don't have permission to perform this action." }
      }, status: :forbidden
    end
  end

  # Pagination parameters
  def page_param
    params[:page]&.to_i || 1
  end

  def per_page_param
    per_page = params[:per_page]&.to_i || 10
    # Limit per_page to prevent abuse
    [per_page, 100].min
  end

  # Sorting parameters
  def sort_by_param
    params[:sort_by]&.to_s
  end

  def sort_direction_param
    direction = params[:sort_direction]&.to_s&.downcase
    %w[asc desc].include?(direction) ? direction : 'asc'
  end

  # Search parameter
  def search_param
    params[:search]&.to_s&.strip
  end

  # Available columns for sorting
  def sortable_columns
    %w[id name last_name email role status created_at updated_at]
  end

  # Apply sorting to the query
  def apply_sorting(relation)
    sort_by = sort_by_param

    if sort_by.present? && sortable_columns.include?(sort_by)
      relation.order("#{sort_by} #{sort_direction_param}")
    else
      relation.order(created_at: :desc) # Default sorting
    end
  end

  # Apply status filter to the query
  def apply_status_filter(relation)
    status = status_param

    if status.present? && valid_status?(status)
      relation.where(status: status)
    else
      relation
    end
  end

  # Status parameter
  def status_param
    params[:status]&.to_s&.strip&.downcase
  end

  # Valid status values
  def valid_status?(status)
    %w[active inactive].include?(status)
  end
end

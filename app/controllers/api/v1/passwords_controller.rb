class Api::V1::PasswordsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_user, only: [ :create ]

  # POST /api/v1/password/forgot
  def create
    if @user
      # Generate reset password token manually
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)

      @user.reset_password_token = hashed_token
      @user.reset_password_sent_at = Time.current

      if @user.save(validate: false)
        # Send the email with the raw token
        UserMailer.reset_password_instructions(@user, raw_token).deliver_now

        render json: {
          message: 'Se ha enviado un correo con instrucciones para recuperar tu contraseña.',
          success: true
        }, status: :ok
      else
        render json: {
          message: 'Hubo un error al procesar tu solicitud. Inténtalo de nuevo.',
          success: false
        }, status: :unprocessable_entity
      end
    else
      render json: {
        message: 'No se encontró un usuario con ese correo electrónico.',
        success: false
      }, status: :not_found
    end
  end

  # PUT/PATCH /api/v1/password/reset
  def update
    @user = User.reset_password_by_token(reset_password_params)

    if @user.errors.empty?
      render json: {
        message: 'Tu contraseña ha sido actualizada exitosamente.',
        success: true
      }, status: :ok
    else
      render json: {
        message: 'Hubo un error al actualizar tu contraseña.',
        errors: @user.errors.full_messages,
        success: false
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(email: password_params[:email])
  end

  def password_params
    params.require(:user).permit(:email)
  end

  def reset_password_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end
end

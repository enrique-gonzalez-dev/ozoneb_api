class UserMailer < ApplicationMailer
  def reset_password_instructions(user, token)
    @user = user
    @token = token
    @reset_url = "#{ENV['FRONTEND_URL']}/reset_password?reset_password_token=#{@token}"

    mail(
      to: @user.email,
      subject: 'Instrucciones para recuperar tu contraseña - Ozone Benefits'
    )
  end

  def invitation_instructions(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @login_url = "#{ENV['FRONTEND_URL']}/login"

    mail(
      to: @user.email,
      subject: 'Bienvenido a Ozone Benefits - Credenciales de acceso'
    )
  end
end

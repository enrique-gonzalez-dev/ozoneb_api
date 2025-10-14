require 'test_helper'

class Api::V1::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
  end

  test "should send password reset instructions for valid email" do
    post "/api/v1/password/forgot", params: {
      user: { email: @user.email }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response['success']
    assert_equal 'Se ha enviado un correo con instrucciones para recuperar tu contraseña.', json_response['message']
  end

  test "should return error for invalid email" do
    post "/api/v1/password/forgot", params: {
      user: { email: 'nonexistent@example.com' }
    }, as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_not json_response['success']
    assert_equal 'No se encontró un usuario con ese correo electrónico.', json_response['message']
  end

  test "should reset password with valid token" do
    @user.send_reset_password_instructions
    reset_token = @user.reload.reset_password_token

    put "/api/v1/password/reset", params: {
      user: {
        reset_password_token: reset_token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response['success']
    assert_equal 'Tu contraseña ha sido actualizada exitosamente.', json_response['message']
  end

  test "should return error for invalid reset token" do
    put "/api/v1/password/reset", params: {
      user: {
        reset_password_token: 'invalid_token',
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not json_response['success']
    assert_equal 'Hubo un error al actualizar tu contraseña.', json_response['message']
  end
end
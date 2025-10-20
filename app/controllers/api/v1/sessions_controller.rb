class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :create ]

  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      if user.active?
        token = generate_jwt_token(user)
        render json: { user: Api::V1::UserSerializer.new(user).as_json, token: token }, status: :ok
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def generate_jwt_token(user)
    JsonWebToken.encode(user_id: user.id)
  end
end

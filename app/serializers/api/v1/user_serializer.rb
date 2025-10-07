class Api::V1::UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: @user.id,
      name: @user.name,
      last_name: @user.last_name,
      role: @user.role,
      email: @user.email
    }
  end
end

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @admin = users(:admin_user)
    @supervisor = users(:supervisor_user)
    @operation = users(:operation_user)
  end

  # Test validations
  test 'should be valid with valid attributes' do
    user = User.new(
      name: 'Test',
      last_name: 'User',
      email: 'test@example.com',
      password: 'password123',
      role: 'operation'
    )
    assert user.valid?
  end

  test 'should require name' do
    user = User.new(
      last_name: 'User',
      email: 'test@example.com',
      password: 'password123',
      role: 'operation'
    )
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test 'should require last_name' do
    user = User.new(
      name: 'Test',
      email: 'test@example.com',
      password: 'password123',
      role: 'operation'
    )
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test 'should assign default role' do
    # Rails enums don't allow nil values, so we test with an invalid creation
    user = User.new(
      name: 'Test',
      last_name: 'User',
      email: 'test@example.com',
      password: 'password123'
      # No role provided
    )

    # The user should be valid with default role assignment
    assert user.valid?
    assert_equal 'operation', user.role # Assuming 'operation' is the default role
  end

  test 'should require unique email' do
    user = User.new(
      name: 'Test',
      last_name: 'User',
      email: @admin.email, # Using existing email
      password: 'password123',
      role: 'operation'
    )
    assert_not user.valid?
    assert_includes user.errors[:email], 'has already been taken'
  end

  test 'should require valid email format' do
    user = User.new(
      name: 'Test',
      last_name: 'User',
      email: 'invalid-email',
      password: 'password123',
      role: 'operation'
    )
    assert_not user.valid?
    assert_includes user.errors[:email], 'is invalid'
  end

  # Test enum roles
  test 'should have correct role values' do
    assert_equal 0, User.roles[:admin]
    assert_equal 1, User.roles[:operation]
    assert_equal 2, User.roles[:supervisor]
  end

  test 'should set role correctly' do
    user = User.new(role: 'admin')
    assert user.admin?
    assert_not user.operation?
    assert_not user.supervisor?

    user.role = 'operation'
    assert user.operation?
    assert_not user.admin?
    assert_not user.supervisor?

    user.role = 'supervisor'
    assert user.supervisor?
    assert_not user.admin?
    assert_not user.operation?
  end

  # Test can_create_users? method
  test 'admin can create users' do
    assert @admin.can_create_users?
  end

  test 'supervisor can create users' do
    assert @supervisor.can_create_users?
  end

  test 'operation user cannot create users' do
    assert_not @operation.can_create_users?
  end

  # Test Devise functionality
  test 'should authenticate with valid password' do
    assert @admin.valid_password?('password123')
  end

  test 'should not authenticate with invalid password' do
    assert_not @admin.valid_password?('wrong_password')
  end

  # Test UUID primary key
  test 'should use UUID as primary key' do
    assert_equal 'id', User.primary_key

    user = User.create!(
      name: 'UUID Test',
      last_name: 'User',
      email: 'uuid@test.com',
      password: 'password123',
      role: 'operation'
    )

    # UUID format: 8-4-4-4-12 characters
    assert_match(/\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i, user.id)
  end

  # Test associations and scopes (if any are added later)
  test 'should respond to role methods' do
    assert_respond_to @admin, :admin?
    assert_respond_to @admin, :operation?
    assert_respond_to @admin, :supervisor?
  end

  # Test edge cases
  test 'should handle role assignment with string' do
    user = User.new(role: 'admin')
    assert_equal 'admin', user.role
    assert user.admin?
  end

  test 'should handle role assignment with integer' do
    user = User.new(role: 0)
    assert_equal 'admin', user.role
    assert user.admin?
  end

  test 'should reject invalid role' do
    assert_raises(ArgumentError) do
      User.new(role: 'invalid_role')
    end
  end

  # Test password requirements (Devise)
  test 'should require minimum password length' do
    user = User.new(
      name: 'Test',
      last_name: 'User',
      email: 'test@example.com',
      password: '123', # Too short
      role: 'operation'
    )
    assert_not user.valid?
    assert_includes user.errors[:password], 'is too short (minimum is 6 characters)'
  end

  test 'should accept valid password length' do
    user = User.new(
      name: 'Test',
      last_name: 'User',
      email: 'test@example.com',
      password: 'password123', # Valid length
      role: 'operation'
    )
    assert user.valid?
  end

  # Test user creation
  test 'should create user with all required attributes' do
    assert_difference 'User.count', 1 do
      User.create!(
        name: 'New',
        last_name: 'User',
        email: 'new@example.com',
        password: 'password123',
        role: 'operation'
      )
    end
  end

  test 'should not create user with missing attributes' do
    assert_no_difference 'User.count' do
      user = User.create(
        email: 'incomplete@example.com',
        password: 'password123'
        # Missing name, last_name, and role
      )
      assert_not user.persisted?
    end
  end
end

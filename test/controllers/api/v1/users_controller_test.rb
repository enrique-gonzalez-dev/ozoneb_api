require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin_user)
    @supervisor = users(:supervisor_user)
    @operation = users(:operation_user)

    # Generate JWT tokens for authentication
    @admin_token = JsonWebToken.encode(user_id: @admin.id)
    @supervisor_token = JsonWebToken.encode(user_id: @supervisor.id)
    @operation_token = JsonWebToken.encode(user_id: @operation.id)

    @valid_user_params = {
      user: {
        name: 'New',
        last_name: 'User',
        email: 'newuser@test.com',
        password: 'password123',
        password_confirmation: 'password123',
        role: 'operation'
      }
    }
  end

  # Helper method to set authorization header
  def auth_headers(token)
    { 'Authorization' => "Bearer #{token}" }
  end

  # Tests for INDEX action
  test 'should get index as admin' do
    get '/api/v1/users', headers: auth_headers(@admin_token)

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 200, response_json['status']['code']
    assert_equal 'Users retrieved successfully.', response_json['status']['message']
    assert response_json['data'].is_a?(Array)
    assert response_json['data'].length >= 3 # At least our 3 fixture users
  end

  test 'should get index as supervisor' do
    get '/api/v1/users', headers: auth_headers(@supervisor_token)

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 200, response_json['status']['code']
  end

  test 'should not get index as operation user' do
    get '/api/v1/users', headers: auth_headers(@operation_token)

    assert_response :forbidden
    response_json = JSON.parse(response.body)
    assert_includes response_json['status']['message'], "don't have permission"
  end

  test 'should not get index without authentication' do
    get '/api/v1/users'

    assert_response :unauthorized
  end

  # Tests for SHOW action
  test 'should show user as admin' do
    get "/api/v1/users/#{@operation.id}", headers: auth_headers(@admin_token)

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 200, response_json['status']['code']
    assert_equal 'User retrieved successfully.', response_json['status']['message']
    assert_equal @operation.id, response_json['data']['id']
    assert_equal @operation.name, response_json['data']['name']
  end

  test 'should show user as supervisor' do
    get "/api/v1/users/#{@operation.id}", headers: auth_headers(@supervisor_token)

    assert_response :ok
  end

  test 'should show user as operation user' do
    get "/api/v1/users/#{@admin.id}", headers: auth_headers(@operation_token)

    assert_response :ok
  end

  test 'should return 404 for non-existent user' do
    get '/api/v1/users/550e8400-e29b-41d4-a716-446655440999', headers: auth_headers(@admin_token)

    assert_response :not_found
    response_json = JSON.parse(response.body)
    assert_equal 'User not found.', response_json['status']['message']
  end

  test 'should not show user without authentication' do
    get "/api/v1/users/#{@admin.id}"

    assert_response :unauthorized
  end

  # Tests for CREATE action
  test 'should create user as admin' do
    assert_difference 'User.count', 1 do
      post '/api/v1/users',
           params: @valid_user_params,
           headers: auth_headers(@admin_token)
    end

    assert_response :created
    response_json = JSON.parse(response.body)
    assert_equal 200, response_json['status']['code']
    assert_equal 'User created successfully.', response_json['status']['message']
    assert_equal 'New', response_json['data']['name']
    assert_equal 'operation', response_json['data']['role']
  end

  test 'should create user as supervisor' do
    assert_difference 'User.count', 1 do
      post '/api/v1/users',
           params: @valid_user_params,
           headers: auth_headers(@supervisor_token)
    end

    assert_response :created
  end

  test 'should not create user as operation user' do
    assert_no_difference 'User.count' do
      post '/api/v1/users',
           params: @valid_user_params,
           headers: auth_headers(@operation_token)
    end

    assert_response :forbidden
  end

  test 'should not create user with invalid params' do
    invalid_params = {
      user: {
        name: '',
        last_name: '',
        email: 'invalid-email',
        password: '123', # Too short
        role: 'operation'
      }
    }

    assert_no_difference 'User.count' do
      post '/api/v1/users',
           params: invalid_params,
           headers: auth_headers(@admin_token)
    end

    assert_response :unprocessable_entity
    response_json = JSON.parse(response.body)
    assert_includes response_json['status']['message'], "couldn't be created"
  end

  test 'should not create user with duplicate email' do
    duplicate_params = @valid_user_params.dup
    duplicate_params[:user][:email] = @admin.email

    assert_no_difference 'User.count' do
      post '/api/v1/users',
           params: duplicate_params,
           headers: auth_headers(@admin_token)
    end

    assert_response :unprocessable_entity
  end

  # Tests for UPDATE action
  test 'should update user as admin' do
    update_params = {
      user: {
        name: 'Updated Name',
        role: 'supervisor'
      }
    }

    patch "/api/v1/users/#{@operation.id}",
          params: update_params,
          headers: auth_headers(@admin_token)

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 'User updated successfully.', response_json['status']['message']
    assert_equal 'Updated Name', response_json['data']['name']
    assert_equal 'supervisor', response_json['data']['role']
  end

  test 'should update user as supervisor' do
    update_params = {
      user: {
        name: 'Updated Name'
      }
    }

    patch "/api/v1/users/#{@operation.id}",
          params: update_params,
          headers: auth_headers(@supervisor_token)

    assert_response :ok
  end

  test 'should allow user to update themselves' do
    update_params = {
      user: {
        name: 'Self Updated'
      }
    }

    patch "/api/v1/users/#{@operation.id}",
          params: update_params,
          headers: auth_headers(@operation_token)

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 'Self Updated', response_json['data']['name']
  end

  test 'should not allow operation user to update other users' do
    update_params = {
      user: {
        name: 'Unauthorized Update'
      }
    }

    patch "/api/v1/users/#{@admin.id}",
          params: update_params,
          headers: auth_headers(@operation_token)

    assert_response :forbidden
    response_json = JSON.parse(response.body)
    assert_includes response_json['status']['message'], "don't have permission"
  end

  test 'should not update user with invalid params' do
    invalid_params = {
      user: {
        name: '',
        email: 'invalid-email'
      }
    }

    patch "/api/v1/users/#{@operation.id}",
          params: invalid_params,
          headers: auth_headers(@admin_token)

    assert_response :unprocessable_entity
    response_json = JSON.parse(response.body)
    assert_includes response_json['status']['message'], "couldn't be updated"
  end

  test 'should not update non-existent user' do
    update_params = {
      user: {
        name: 'Updated Name'
      }
    }

    patch '/api/v1/users/550e8400-e29b-41d4-a716-446655440999',
          params: update_params,
          headers: auth_headers(@admin_token)

    assert_response :not_found
  end

  # Tests for DESTROY action
  test 'should destroy user as admin' do
    user_to_delete = User.create!(
      name: 'To Delete',
      last_name: 'User',
      email: 'delete@test.com',
      password: 'password123',
      role: 'operation'
    )

    assert_difference 'User.count', -1 do
      delete "/api/v1/users/#{user_to_delete.id}",
             headers: auth_headers(@admin_token)
    end

    assert_response :ok
    response_json = JSON.parse(response.body)
    assert_equal 'User deleted successfully.', response_json['status']['message']
  end

  test 'should destroy user as supervisor' do
    user_to_delete = User.create!(
      name: 'To Delete',
      last_name: 'User',
      email: 'delete2@test.com',
      password: 'password123',
      role: 'operation'
    )

    assert_difference 'User.count', -1 do
      delete "/api/v1/users/#{user_to_delete.id}",
             headers: auth_headers(@supervisor_token)
    end

    assert_response :ok
  end

  test 'should not destroy user as operation user' do
    assert_no_difference 'User.count' do
      delete "/api/v1/users/#{@admin.id}",
             headers: auth_headers(@operation_token)
    end

    assert_response :forbidden
  end

  test 'should not destroy non-existent user' do
    delete '/api/v1/users/550e8400-e29b-41d4-a716-446655440999',
           headers: auth_headers(@admin_token)

    assert_response :not_found
  end

  # Tests for authentication and authorization
  test 'should require authentication for all actions' do
    # Test all actions without authentication
    get '/api/v1/users'
    assert_response :unauthorized

    get "/api/v1/users/#{@admin.id}"
    assert_response :unauthorized

    post '/api/v1/users', params: @valid_user_params
    assert_response :unauthorized

    patch "/api/v1/users/#{@admin.id}", params: { user: { name: 'Test' } }
    assert_response :unauthorized

    delete "/api/v1/users/#{@admin.id}"
    assert_response :unauthorized
  end

  test 'should reject invalid JWT token' do
    invalid_token = 'invalid.jwt.token'

    get '/api/v1/users', headers: { 'Authorization' => "Bearer #{invalid_token}" }
    assert_response :unauthorized
  end

  # Tests for parameter filtering
  test 'should filter role parameter for operation users when updating' do
    # This test verifies that operation users cannot change roles
    # even if they try to include role in their update

    update_params = {
      user: {
        name: 'Updated Name',
        role: 'admin' # This should be filtered out
      }
    }

    patch "/api/v1/users/#{@operation.id}",
          params: update_params,
          headers: auth_headers(@operation_token)

    assert_response :ok

    # Reload the user to check that role wasn't changed
    @operation.reload
    assert_equal 'operation', @operation.role # Should still be operation
    assert_equal 'Updated Name', @operation.name # But name should be updated
  end

  # Test serializer output
  test 'should return serialized user data' do
    get "/api/v1/users/#{@admin.id}", headers: auth_headers(@admin_token)

    assert_response :ok
    response_json = JSON.parse(response.body)
    user_data = response_json['data']

    # Should include these fields
    assert user_data.key?('id')
    assert user_data.key?('name')
    assert user_data.key?('last_name')
    assert user_data.key?('role')
    assert user_data.key?('email')

    # Should match the actual user data
    assert_equal @admin.id, user_data['id']
    assert_equal @admin.name, user_data['name']
    assert_equal @admin.last_name, user_data['last_name']
    assert_equal @admin.role, user_data['role']
    assert_equal @admin.email, user_data['email']
  end
end

require 'test_helper'

class Api::V1::BranchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @branch = branches(:one)
    @user = users(:admin_user)
    @token = JsonWebToken.encode(user_id: @user.id)
    @auth_headers = { 'Authorization' => "Bearer #{@token}" }
  end

  test 'should get index' do
    get api_v1_branches_url, headers: @auth_headers
    assert_response :success
  end

  test 'should show branch' do
    get api_v1_branch_url(@branch), headers: @auth_headers
    assert_response :success
  end

  test 'should create branch' do
    post api_v1_branches_url, params: { branch: { name: 'Nueva Sucursal', branch_type: 'production' } }, headers: @auth_headers
    assert_response :success
  end
end

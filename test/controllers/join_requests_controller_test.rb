require 'test_helper'

class JoinRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @join_request = join_requests(:one)
  end

  test "should get index" do
    get join_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_join_request_url
    assert_response :success
  end

  test "should create join_request" do
    assert_difference('JoinRequest.count') do
      post join_requests_url, params: { join_request: { commoner_id: @join_request.commoner_id, group_id: @join_request.group_id, status: @join_request.status } }
    end

    assert_redirected_to join_request_url(JoinRequest.last)
  end

  test "should show join_request" do
    get join_request_url(@join_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_join_request_url(@join_request)
    assert_response :success
  end

  test "should update join_request" do
    patch join_request_url(@join_request), params: { join_request: { commoner_id: @join_request.commoner_id, group_id: @join_request.group_id, status: @join_request.status } }
    assert_redirected_to join_request_url(@join_request)
  end

  test "should destroy join_request" do
    assert_difference('JoinRequest.count', -1) do
      delete join_request_url(@join_request)
    end

    assert_redirected_to join_requests_url
  end
end

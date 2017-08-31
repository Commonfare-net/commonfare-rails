require 'test_helper'

class CommonersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @commoner = commoners(:one)
  end

  test "should get index" do
    get commoners_url
    assert_response :success
  end

  test "should get new" do
    get new_commoner_url
    assert_response :success
  end

  test "should create commoner" do
    assert_difference('Commoner.count') do
      post commoners_url, params: { commoner: { name: @commoner.name } }
    end

    assert_redirected_to commoner_url(Commoner.last)
  end

  test "should show commoner" do
    get commoner_url(@commoner)
    assert_response :success
  end

  test "should get edit" do
    get edit_commoner_url(@commoner)
    assert_response :success
  end

  test "should update commoner" do
    patch commoner_url(@commoner), params: { commoner: { name: @commoner.name } }
    assert_redirected_to commoner_url(@commoner)
  end

  test "should destroy commoner" do
    assert_difference('Commoner.count', -1) do
      delete commoner_url(@commoner)
    end

    assert_redirected_to commoners_url
  end
end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should show user" do
    get :show, :id => users(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    login_as :one
    get :edit, :id => users(:one).to_param
    assert_response :success
  end

  test "should update user" do
    login_as :one
    put :update, :id => users(:one).to_param, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  test "export happy path" do
    login_as :one
    get :export
    assert_response :success
  end

  test "export sends shit to xml" do
    login_as :terry
    get :export
    terry_xml = users(:terry).tweets.to_xml(:except => [:sticky, :score, :user_id, :updated_at])
    assert_equal terry_xml, @response.body
  end
end

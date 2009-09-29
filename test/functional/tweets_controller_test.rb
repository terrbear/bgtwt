require 'test_helper'

class TweetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get recents feed" do
    get :recent_feed
    assert_response :success
  end

  test "should get user's feed" do
    get :user_feed, :id => users(:terry).id
    assert_response :success
  end

  test "should get M&S feed" do
    get :ms_feed
    assert_response :success
  end

  test "should get edit" do
    login_as :terry
    get :edit, :id => users(:terry).tweets.first.id
    assert_response :success
  end

  test "edit should require ownership" do
    get :edit, :id => Tweet.find(:first).id
    assert_response :redirect
  end

  test "should post to update" do
    login_as :terry
    tweet = users(:terry).tweets.first
    post :update, :tweet => {:body => "omgbbq"}, :id => tweet.id
    assert_equal "Tweet updated!", flash[:notice]
    assert_response :redirect
    assert_redirected_to :controller => :tweets, :action => :show, :id => tweet.code, :format => :html
  end

  test "update should require ownership" do
    tweet = users(:terry).tweets.first
    post :update, :tweet => {:body => "omgbbq"}, :id => tweet.id
    assert_equal "You can't edit that tweet.", flash[:notice]
    assert_response :redirect
    assert_redirected_to :controller => :tweets, :action => :index
  end

  test "should get updates" do
    get :updates, :id => Tweet.find(:first).id, :viewed => Time.now.utc.to_s
    assert_response 400
  end

  test "should get show" do
    get :show, :id => Tweet.parents.find(:first).id
    assert_response :success
  end

  test "should create" do
    post :create, :tweet => {:body => "ahoy"}
    flash[:notice] = "Whoah! That's a big tweet!"
    assert_response :redirect
  end

  test "should reply" do
    post :reply, :tweet => {:body => "bang"}, :parent_id => Tweet.parents.find(:first).id
    assert_response :success
  end

  test "should stick" do
    login_as :admin
    get :stick, :id => Tweet.find(:first).id
    assert_response :redirect
    assert_redirected_to :controller => :tweets, :action => :show, :id => Tweet.find(:first).code
  end

  test "should unstick" do
    login_as :admin
    get :unstick, :id => Tweet.find(:first).id
    assert_response :redirect
    assert_redirected_to :controller => :tweets, :action => :show, :id => Tweet.find(:first).code
  end

  test "sticky requires admin" do
    login_as :sara
    get :unstick, :id => Tweet.find(:first).id
    assert_response :redirect
    assert_redirected_to :controller => :sessions, :action => :new
  end

  test "unsticky requires admin" do
    login_as :sara
    get :unstick, :id => Tweet.find(:first).id
    assert_response :redirect
    assert_redirected_to :controller => :sessions, :action => :new
  end

  test "can delete" do
    login_as :admin
    get :delete, :id => Tweet.find(:first).id
    assert_response :redirect
    assert_redirected_to :controller => :tweets, :action => :index
    assert_equal "Tweet deleted.", flash[:notice]
  end

  test "only admins can delete" do
    login_as :sara
    get :delete, :id => Tweet.find(:first).id
    assert_response :redirect
    assert_redirected_to :controller => :sessions, :action => :new
  end

  test "should get firehose" do
    get :firehose
    assert_response :success
  end
end

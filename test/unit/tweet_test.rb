require 'test_helper'
require 'mocha'


class TweetTest < ActiveSupport::TestCase
  test "sanity check on fixtures" do
    assert Tweet.count > 10
  end

  test "recent happy path" do
    assert Tweet.recent(5).find(:all).size == 5
  end

  test "calc shakers resets most tweets score to 0" do
    Tweet.calc_shakers
    Tweet.find(:all, :order => "created_at", :limit => 100).each do |twt|
      assert_equal 0, twt.score, "tweet #{twt.id} score wasn't reset!"
    end
  end

  test "shakiness for highest" do
    assert tweets(:highest_ranked).shakiness == 5
  end 

  test "calc shakiness gets highest ranked on top" do
    Tweet.calc_shakers
    assert Tweet.shakers.first == tweets(:highest_ranked)
    assert Tweet.shakers.include?(tweets(:old_highest_ranked))
  end

  test "shakers doesnt return any tweets with score 0" do
    Tweet.calc_shakers
    Tweet.shakers.each do |shaker|
      assert shaker.score > 0
    end
  end

  test "editable is false for non-author" do
    assert !Tweet.find(:first).editable?(users(:sara))
  end

  test "editable is true for author" do
    t = users(:sara)
    tw = Tweet.new(:author => t)
    assert tw.editable?(t)
  end

  test "admins can edit anyone's tweets" do
    tw = Tweet.new(:author => users(:sara))
    assert tw.editable?(users(:admin))
  end

  test "stick tweet" do
    t = Tweet.find(:first)
    t.stick!
    assert t.sticky?
  end

  test "unstick tweet" do
    t = Tweet.find(:first)
    t.update_attribute(:sticky, true)
    t.unstick!
    assert !t.sticky?
  end

  test "title happy path" do
    assert_nothing_raised{Tweet.find(:first).title}
  end

  test "title implies first 25 chars if blank" do
    assert Tweet.find(:first).attributes['title'].nil?, "tweet has a title, isn't really valid"
    assert_equal Tweet.find(:first).body[0, 25], Tweet.find(:first).title
  end
end

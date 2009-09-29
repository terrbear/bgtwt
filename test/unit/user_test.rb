require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "tagline happy path" do
    assert_nothing_raised{User.tagline}
  end
end

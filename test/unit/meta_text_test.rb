require 'test_helper'

class MetaTextTest < ActiveSupport::TestCase
  include MetaText::Twitter
  include MetaText::Hashtag
  include MetaText::Link

  test "happy path for twitter handles" do
    assert_equal "\"@terrbear\":http://www.twitter.com/terrbear", populate_twitter_links("@terrbear")
  end

  test "happy path for hashtag links" do
    assert_equal "\"#whatever\":http://www.hashtags.org/tag/whatever", populate_hashtag_links("#whatever") 
  end

  test "newlines don't fuckup twitter names" do
    assert_equal "\n\"@terrbear\":http://www.twitter.com/terrbear", populate_twitter_links("\n@terrbear")
  end

  test "string extension happy path" do
    s = "@terrbear #whatever http://www.google.com".meta_filter!
    assert s.include?("\"@terrbear\":http://www.twitter.com/terrbear")
    assert s.include?("\"#whatever\":http://www.hashtags.org/tag/whatever")
    assert s.include?("\"http://www.google.com\":http://www.google.com")
  end

  test "meta_filter isn't destructive" do
    s = "@terrbear hello"
    s2 = s.meta_filter
    assert_equal "@terrbear hello", s
  end

  test "happy path for autolink entry" do
    assert_equal "hello \"http://www.google.com\":http://www.google.com there", populate_links("hello http://www.google.com there")
    assert populate_links("http://terrbear") == "\"http://terrbear\":http://terrbear"
  end

  test "image links aren't borked by link metatext" do
    assert populate_links("!http://terry!") == "!http://terry!"
  end

  test "content after slashies is preserved for user viewing" do
    assert_equal "hi \"http://www.g.com/whatevz\":http://www.g.com/whatevz", populate_links("hi http://www.g.com/whatevz") 
  end
end

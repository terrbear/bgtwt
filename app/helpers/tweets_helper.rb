module TweetsHelper
  def filter_body(body, abbrev = false)
    newbody = RedCloth.new(sanitize(body.meta_filter)).to_html
    newbody = newbody.blank? ? "&nbsp;" : newbody
    (abbrev && newbody.length > 140) ? "#{h newbody[0, 140]} ..." : newbody
  end

  def super_short(tweet)
    if tweet.author.nil?
      truncate(tweet.body, :length => 15)
    else
      "#{tweet.author.handle(:at => false)}: #{truncate(tweet.body, :length => 10)}"
    end
  end

  def user_link_from_tweet(tweet)
    if tweet.author
      link_to(tweet.author.handle, tweet.author) 
    else
      "Anonymous"
    end
  end
end

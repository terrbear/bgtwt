class TweetObserver < ActiveRecord::Observer
  def after_create(tweet)
    Rails.logger.debug{"observing creating a tweet: #{tweet.inspect} is a reply? #{tweet.reply?}"}
    return if RAILS_ENV != "production"
    if tweet.reply?
      tweet.parent.async_send(:notify_tweeps!, tweet)
    else
      tweet.async_send(:notify_world!)
    end
  end
end

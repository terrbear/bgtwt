class Tweet < ActiveRecord::Base
  include MetaText::Hashtag
  #could include something else here

  validates_presence_of :body
  has_many :replies, 
    :class_name => "Tweet", 
    :order => "created_at", 
    :foreign_key => "parent_id",
    :dependent => :destroy

  belongs_to :parent,
    :class_name => "Tweet",
    :foreign_key => "parent_id"
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"

  named_scope :public, {:conditions => {:secret => false}}
  named_scope :parents, {:conditions => "parent_id = 0"}
  named_scope :recent, lambda{|limit| {:order => "created_at desc", :limit => limit}}
  named_scope :stickies, {:conditions => {:sticky => true}, :order => "updated_at desc"}
  named_scope :ignore_user, lambda{|user|
    user.nil? ? 
      {:conditions => "user_id is not null"} :
      {:conditions => ["user_id is null or user_id != ?", user.id]}
  }

  def editable?(user)
    return false if user.nil?
    user.admin? || (self.author && (self.author == user))
  end

  def stick!
    self.update_attribute(:sticky, true)
  end

  def unstick!
    self.update_attribute(:sticky, false)
  end

  def self.calc_shakers
    Tweet.transaction do
      Tweet.update_all("score = 0")
      reducer = 1
      Tweet.public.parents.recent(50).each_with_index do |twt, index|
        reducer *= 2 if index % 5 == 0 && index != 0
        twt.update_attribute(:score, twt.shakiness(reducer)) 
      end
    end
  end

  def author_name
    if self.author
      self.author.handle || "Unknown"
    else
      "Anonymous"
    end
  end

  def shakiness(reducer = 1)
    self.replies.count / reducer
  end

  def self.shakers
    self.public.parents.find(:all, :order => "score desc", :limit => 10, :conditions => "score > 0")
  end

  def reply?
    parent_id.to_i != 0
  end

  def parent?
    parent.nil? || parent_id.to_i == 0
  end

  def excerpt
    #format looks like
    #from @terrbear: the rain in spain looks like 
    ##hashtag1 #hashtag2 #hashtag3 http://bgtwt.com/123
    tags = " #{self.hashtags(body)[0, 3].join(" ")} "
    attribution = "from #{self.author_name}: "
    leftover = 140 - (tags.length + self.permalink.length + attribution.length) 
    "#{attribution}#{self.body.gsub(/(\r\n)|\n|\r/, ' ')[0, leftover]}#{tags}#{self.permalink}"
  end

  def notify_tweeps!(tweet)
    return  #you'll have to get your own user and hope twitter doesn't bork you
            #with fairly arbitrary spam standards 
    #
    return if tweet.author_name =~ /anonymous/i
	  twitter = Twitter::Client.new(:login => "yourlogin", :password => "yourpasswd")
	
	  link = tweet.permalink

    tweeter = tweet.author_name

	  self.tweeps.each do |name|
      next if name.sub(/@/, '') == tweet.author_name.sub(/@/, '')
	    twitter.status(:post, "@#{name} new comment from #{tweeter.gsub(/@/, '')}: #{link}")
	  end

  rescue Twitter::RESTError
    logger.error{"twitter is down. not sending out updates."}
  end

  def self.search(search_string)
    self.public.find(:all, :conditions => ['body like ?', "%#{search_string}%"])
  end

  def notify_world!
    return if self.secret?
    return if self.author_name =~ /anonymous/i
	  twitter = Twitter::Client.new(:login => "yourlogin", :password => "yourpasswd")
    twitter.status(:post, self.excerpt)
  rescue Twitter::RESTError
    logger.error{"twitter is down. not sending out updates."}
  end

  def tweeps
    ([self] + self.replies).map do |t|
      t.author ? t.author.twitter : nil
    end.compact.uniq
  end

  def permalink(server = SERVER_NAME)
    if self.reply?
      "http://#{server}/#{self.parent.code}##{self.id}"
    else
      "http://#{server}/#{self.code}"
    end
  end

  def root_code
    self.reply? ? self.parent.code : self.code
  end

  def code
    self.id.to_62
  end

  def self.find_by_code(code)
    self.find(code.from_62) 
  rescue ActiveRecord::RecordNotFound
    self.find(code)
  end

  def title(args = {})
    args.reverse_merge!(:short => false)
    if read_attribute(:title).blank? 
      self.body[0, 25] 
    else
      if args[:short]
        read_attribute(:title)[0, 25]
      else
        read_attribute(:title)
      end
    end
  end
end

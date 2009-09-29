class User < ActiveRecord::Base
  has_many :tweets, :order => 'created_at desc'

  validates_uniqueness_of :twitter, :allow_nil => true

  def self.tagline
    User.find(:all, :conditions => "tagline is not null and length(tagline) > 0").rand.tagline
  end

  def handle(opts = {})
    opts.reverse_merge!(:at => true)
	  return "Unknown" if self.twitter.blank? && self.name.blank?
    if self.twitter.blank?
      self.name
    elsif opts[:at]
      "@#{self.twitter}"
    else
      "#{self.twitter}"
    end
  end

  def has_twitter?
    !self.twitter.blank?
  end

	def email
		read_attribute(:email).to_s
	end
end

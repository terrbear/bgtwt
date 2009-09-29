class DitchUserField < ActiveRecord::Migration
  def self.up
    Tweet.find(:all).each do |t|
      next if t.author
      next if t.user.blank?
      t.update_attribute(:user_id, User.find_by_twitter(t.user.gsub(/@/, '')))
    end
    remove_column :tweets, :user
  end

  def self.down
  end
end

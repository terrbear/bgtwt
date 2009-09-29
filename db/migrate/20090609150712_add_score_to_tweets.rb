class AddScoreToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :score, :integer, :default => 0
  end

  def self.down
    remove_column :tweets, :score
  end
end

class AddTitlesToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :title, :string, :default => nil
  end

  def self.down
    remove_column :tweets, :title
  end
end

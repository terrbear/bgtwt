class AddSecretToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :secret, :boolean, :default => false
  end

  def self.down
    remove_column :tweets, :secret
  end
end

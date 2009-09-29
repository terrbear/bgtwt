class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.string :user
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end

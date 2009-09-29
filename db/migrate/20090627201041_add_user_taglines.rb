class AddUserTaglines < ActiveRecord::Migration
  def self.up
    add_column :users, :tagline, :string, :default => "for when your thoughts exceed 140 characters"
  end

  def self.down
    remove_column :users, :tagline
  end
end

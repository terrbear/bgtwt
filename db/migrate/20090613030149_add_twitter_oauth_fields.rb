class AddTwitterOauthFields < ActiveRecord::Migration
  def self.up
    add_column :users, :token, :string
    add_column :users, :secret, :string
  end

  def self.down
    remove_column :users, :token
    remove_column :users, :secret
  end
end

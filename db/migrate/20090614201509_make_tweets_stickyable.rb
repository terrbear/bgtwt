class MakeTweetsStickyable < ActiveRecord::Migration
  def self.up
    add_column :tweets, :sticky, :boolean, :default => false
  end

  def self.down
    remove_column :tweets, :sticky
  end
end

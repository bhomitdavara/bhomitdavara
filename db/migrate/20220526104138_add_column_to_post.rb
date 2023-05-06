class AddColumnToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :total_comments, :integer, default: 0
    add_column :posts, :total_likes, :integer, default: 0
  end
end

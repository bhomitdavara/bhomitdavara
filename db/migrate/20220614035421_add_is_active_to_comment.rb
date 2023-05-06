class AddIsActiveToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :is_active, :boolean, default: true
    add_column :sub_comments, :is_active, :boolean, default: true
  end
end

class AddStatusToComment < ActiveRecord::Migration[7.0]
  def up
    add_column :comments, :status, :integer, default: 0
    change_column_null :comments, :user_id, true
  end

  def down
    remove_column :comments, :status
    change_column_null :comments, :user_id, false
  end
end

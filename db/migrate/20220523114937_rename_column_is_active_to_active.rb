class RenameColumnIsActiveToActive < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :is_active, :active
  end
end

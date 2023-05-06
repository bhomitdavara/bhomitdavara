class AddColumnInTheReport < ActiveRecord::Migration[7.0]
  def change
    add_column :reports, :is_delete, :boolean, default: 0
  end
end

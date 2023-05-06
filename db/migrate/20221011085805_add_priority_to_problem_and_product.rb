class AddPriorityToProblemAndProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :priority, :integer, default: 0
    add_column :products, :priority, :integer, default: 0
  end
end

class AddPriorityToFertilizerSchedule < ActiveRecord::Migration[7.0]
  def change
    add_column :fertilizer_schedules, :priority, :integer, default: 0
  end
end

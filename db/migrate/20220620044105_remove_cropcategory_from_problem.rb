class RemoveCropcategoryFromProblem < ActiveRecord::Migration[7.0]
  def change
    remove_column :problems, :crop_category_id
    remove_column :fertilizer_schedules, :crop_category_id
  end
end

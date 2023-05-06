class AddCropToProblems < ActiveRecord::Migration[7.0]
  def change
    add_reference :problems, :crop, null: false, foreign_key: true
    add_reference :fertilizer_schedules, :crop, null: false, foreign_key: true
  end
end

class CreateFertilizerSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :fertilizer_schedules do |t|
      t.string :day_duration_en
      t.string :day_duration_gu
      t.string :day_duration_hi
      t.string :date_duration_en
      t.string :date_duration_gu
      t.string :date_duration_hi
      t.string :note_en
      t.string :note_gu
      t.string :note_hi
      t.boolean :active, default: true
      t.references :crop_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateFertilizerItems < ActiveRecord::Migration[7.0]
  def change
    create_table :fertilizer_items do |t|
      t.references :fertilizer_schedule, null: false, foreign_key: true
      t.string :fertilizer_en
      t.string :fertilizer_gu
      t.string :fertilizer_hi
      t.string :advice_en
      t.string :advice_gu
      t.string :advice_hi
      t.string :cost

      t.timestamps
    end
  end
end

class CreateCrops < ActiveRecord::Migration[7.0]
  def change
    create_table :crops do |t|
      t.string :name_gu
      t.string :name_en
      t.string :name_hi

      t.timestamps
    end
  end
end

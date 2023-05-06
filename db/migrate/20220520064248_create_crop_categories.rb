class CreateCropCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :crop_categories do |t|
      t.string :name_gu
      t.string :name_en
      t.string :name_hi
      t.references :crop, null: false, foreign_key: true

      t.timestamps
    end
  end
end

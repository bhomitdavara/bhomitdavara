class CreateProblems < ActiveRecord::Migration[7.0]
  def change
    create_table :problems do |t|
      t.string :title_en
      t.string :title_gu
      t.string :title_hi
      t.string :discription_en
      t.string :discription_gu
      t.string :discription_hi
      t.integer :tags, array: true, default: []
      t.boolean :active, default: true
      t.references :crop_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end

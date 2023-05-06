class CreateSolutions < ActiveRecord::Migration[7.0]
  def change
    create_table :solutions do |t|
      t.string :title_en
      t.string :title_gu
      t.string :title_hi
      t.string :discription_en
      t.string :discription_gu
      t.string :discription_hi
      t.string :sub_title_en
      t.string :sub_title_gu
      t.string :sub_title_hi
      t.references :problem, null: false, foreign_key: true

      t.timestamps
    end
  end
end

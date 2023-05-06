class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.integer :product_type
      t.string :title_en
      t.string :title_gu
      t.string :title_hi
      t.integer :tags, array: true, default: []
      t.string :other_details_en
      t.string :other_details_gu
      t.string :other_details_hi
      t.string :discription_en
      t.string :discription_gu
      t.string :discription_hi
      t.boolean :active, default: true
      t.references :crop_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end

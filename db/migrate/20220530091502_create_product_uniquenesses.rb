class CreateProductUniquenesses < ActiveRecord::Migration[7.0]
  def change
    create_table :product_uniquenesses do |t|
      t.string :title_en
      t.string :title_gu
      t.string :title_hi
      t.string :sub_title_en
      t.string :sub_title_gu
      t.string :sub_title_hi
      t.string :discription_en
      t.string :discription_gu
      t.string :discription_hi
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end

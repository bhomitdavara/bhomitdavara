class CreateProductTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :product_types do |t|
      t.string :title_en
      t.string :title_gu
      t.string :title_hi

      t.timestamps
    end
  end
end

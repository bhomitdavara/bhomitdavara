class ChangeColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :feedbacks, :discription, :description
    rename_column :problems, :discription_en, :description_en
    rename_column :problems, :discription_gu, :description_gu
    rename_column :problems, :discription_hi, :description_hi
    rename_column :solutions, :discription_en, :description_en
    rename_column :solutions, :discription_gu, :description_gu
    rename_column :solutions, :discription_hi, :description_hi
    rename_column :product_uniquenesses, :discription_en, :description_en
    rename_column :product_uniquenesses, :discription_gu, :description_gu
    rename_column :product_uniquenesses, :discription_hi, :description_hi
    rename_column :products, :discription_en, :description_en
    rename_column :products, :discription_gu, :description_gu
    rename_column :products, :discription_hi, :description_hi
  end
end

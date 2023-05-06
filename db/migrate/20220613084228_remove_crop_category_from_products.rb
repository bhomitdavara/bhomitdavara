class RemoveCropCategoryFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_reference :products, :crop_category, null: false, foreign_key: true
  end
end

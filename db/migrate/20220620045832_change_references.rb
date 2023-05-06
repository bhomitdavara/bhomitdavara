class ChangeReferences < ActiveRecord::Migration[7.0]
  def change
    remove_column :crop_categories, :crop_id
    add_reference :crops, :crop_category, null: true, foreign_key: true
  end
end

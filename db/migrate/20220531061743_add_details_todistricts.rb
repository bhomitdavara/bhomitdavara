class AddDetailsTodistricts < ActiveRecord::Migration[7.0]
  def change
    add_column :districts, :name_gu, :string
    add_column :districts, :name_hi, :string
    rename_column :districts, :name, :name_en
  end
end

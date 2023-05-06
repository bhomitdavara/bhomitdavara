class AddDetailsToSoilType < ActiveRecord::Migration[7.0]
  def change
    add_column :soil_types, :name_gu, :string
    add_column :soil_types, :name_hi, :string
    rename_column :soil_types, :name, :name_en
  end
end

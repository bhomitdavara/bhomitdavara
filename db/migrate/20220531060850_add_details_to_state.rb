class AddDetailsToState < ActiveRecord::Migration[7.0]
  def change
    add_column :states, :name_gu, :string
    add_column :states, :name_hi, :string
    rename_column :states, :name, :name_en
  end
end

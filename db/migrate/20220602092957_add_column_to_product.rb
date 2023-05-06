class AddColumnToProduct < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :product_type, null: false, foreign_key: true
    remove_column :products, :product_type, :integer
  end
end

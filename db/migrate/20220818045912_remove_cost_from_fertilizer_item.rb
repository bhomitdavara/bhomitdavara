class RemoveCostFromFertilizerItem < ActiveRecord::Migration[7.0]
  def change
    remove_column :fertilizer_items, :cost, :string
  end
end

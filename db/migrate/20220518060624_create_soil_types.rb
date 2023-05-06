class CreateSoilTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :soil_types do |t|
      t.string :name

      t.timestamps
    end
  end
end

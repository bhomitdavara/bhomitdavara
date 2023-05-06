class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name, default: ''
      t.string :last_name, default: ''
      t.string :village, default: ''
      t.string :mobile_no
      t.string :otp
      t.integer :language
      t.boolean :is_active, default: false
      t.integer :favourite_crops, array: true, default: []
      t.references :state, null: true, foreign_key: true, default: ''
      t.references :district, null: true, foreign_key: true, default: ''
      t.references :soil_type, null: true, foreign_key: true, default: ''

      t.timestamps
    end
  end
end

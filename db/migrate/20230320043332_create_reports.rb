class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.string :description
      t.integer :user_id, null: false, foreign_key: true
      t.integer :reported_user_id, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end

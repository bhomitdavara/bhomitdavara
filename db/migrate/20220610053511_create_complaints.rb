class CreateComplaints < ActiveRecord::Migration[7.0]
  def change
    create_table :complaints do |t|
      t.references :post, null: true, foreign_key: true, default: ''
      t.references :comment, null: true, foreign_key: true, default: ''
      t.references :sub_comment, null: true, foreign_key: true, default: ''
      t.references :user, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end

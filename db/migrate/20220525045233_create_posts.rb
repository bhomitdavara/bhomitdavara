class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :discription
      t.integer :status
      t.integer :post_type
      t.integer :tags, array: true, default: []
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateBlockedUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :blocked_users do |t|
      t.integer :user_id, null: false, foreign_key: true
      t.integer :blocked_user_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end

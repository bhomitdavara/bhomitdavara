class CreateMaintenances < ActiveRecord::Migration[7.0]
  def change
    create_table :maintenances do |t|
      t.string :devise_tokens
      t.boolean :status, default: false
      t.string :message
      t.integer :allowed_users, array: true, default: []

      t.timestamps
    end
  end
end

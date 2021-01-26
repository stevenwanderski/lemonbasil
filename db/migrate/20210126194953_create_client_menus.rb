class CreateClientMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :client_menus do |t|
      t.integer :client_id
      t.datetime :due_at
      t.text :message
      t.string :slug

      t.timestamps
    end
  end
end

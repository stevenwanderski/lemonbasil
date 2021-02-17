class CreateClientMenuSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :client_menu_submissions do |t|
      t.integer :client_menu_id
      t.text :message

      t.timestamps
    end
  end
end

class CreateClientMenuSelections < ActiveRecord::Migration[6.0]
  def change
    create_table :client_menu_selections do |t|
      t.integer :client_menu_submission_id
      t.integer :client_menu_item_id
      t.text :message

      t.timestamps
    end
  end
end

class CreateInstructions < ActiveRecord::Migration[6.0]
  def change
    create_table :instructions do |t|
      t.integer :client_menu_selection_id, null: false
      t.text :text

      t.timestamps
    end
  end
end

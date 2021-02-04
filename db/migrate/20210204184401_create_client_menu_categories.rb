class CreateClientMenuCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :client_menu_categories do |t|
      t.string :name
      t.text :description
      t.integer :weight
      t.integer :client_menu_id

      t.timestamps
    end
  end
end

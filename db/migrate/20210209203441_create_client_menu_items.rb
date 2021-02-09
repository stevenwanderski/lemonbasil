class CreateClientMenuItems < ActiveRecord::Migration[6.0]
  def change
    create_table :client_menu_items do |t|
      t.string :name
      t.text :description
      t.string :cost
      t.string :quantity
      t.integer :weight
      t.integer :client_menu_category_id

      t.timestamps
    end
  end
end

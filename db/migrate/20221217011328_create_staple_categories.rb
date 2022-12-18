class CreateStapleCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :staple_categories do |t|
      t.string :name
      t.integer :staple_id
      t.integer :client_menu_id
      t.integer :weight, default: 0

      t.timestamps
    end
  end
end

class CreateMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :menus do |t|
      t.string :name, null: false
      t.text :description
      t.string :category

      t.timestamps
    end
  end
end

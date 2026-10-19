class CreateLemonDropGroceryListSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_grocery_list_sections do |t|
      t.string :heading

      t.timestamps
    end

    create_table :lemon_drop_grocery_groups do |t|
      t.references :grocery_list_section, null: false, foreign_key: { to_table: :lemon_drop_grocery_list_sections }
      t.string :name
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :lemon_drop_grocery_items do |t|
      t.references :grocery_group, null: false, foreign_key: { to_table: :lemon_drop_grocery_groups }
      t.text :text, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end

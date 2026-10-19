class CreateLemonDropRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_recipes do |t|
      t.references :recipes_section, null: false, foreign_key: { to_table: :lemon_drop_recipes_sections }
      t.integer :position, null: false, default: 0
      t.string :title, null: false
      t.string :slug, null: false
      t.string :kicker
      t.string :category
      t.string :menu_title
      t.text :menu_blurb
      t.integer :prep_minutes
      t.integer :cook_minutes
      t.string :time_note
      t.string :total_label
      t.integer :serves
      t.text :tip
      t.string :hero_focus, null: false, default: 'center'

      t.timestamps
    end

    add_index :lemon_drop_recipes, [:recipes_section_id, :position]
  end
end

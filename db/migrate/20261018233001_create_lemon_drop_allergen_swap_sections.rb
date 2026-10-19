class CreateLemonDropAllergenSwapSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_allergen_swap_sections do |t|
      t.string :heading
      t.text :disclaimer

      t.timestamps
    end

    create_table :lemon_drop_swap_groups do |t|
      t.references :allergen_swap_section, null: false, foreign_key: { to_table: :lemon_drop_allergen_swap_sections }
      t.string :name
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :lemon_drop_swaps do |t|
      t.references :swap_group, null: false, foreign_key: { to_table: :lemon_drop_swap_groups }
      t.string :from_text, null: false
      t.string :to_text, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :lemon_drop_swap_recipes do |t|
      t.references :allergen_swap_section, null: false, foreign_key: { to_table: :lemon_drop_allergen_swap_sections }
      t.string :title, null: false
      t.string :yield_label
      t.text :ingredients
      t.text :steps
      t.string :use_for
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end

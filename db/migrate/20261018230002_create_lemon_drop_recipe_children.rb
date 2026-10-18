class CreateLemonDropRecipeChildren < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_ingredient_groups do |t|
      t.references :recipe, null: false, foreign_key: { to_table: :lemon_drop_recipes }
      t.string :name
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :lemon_drop_ingredients do |t|
      t.references :ingredient_group, null: false, foreign_key: { to_table: :lemon_drop_ingredient_groups }
      t.text :text, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :lemon_drop_steps do |t|
      t.references :recipe, null: false, foreign_key: { to_table: :lemon_drop_recipes }
      t.text :body, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end

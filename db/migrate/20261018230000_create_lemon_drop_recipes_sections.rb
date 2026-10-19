class CreateLemonDropRecipesSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_recipes_sections do |t|
      t.string :heading

      t.timestamps
    end
  end
end

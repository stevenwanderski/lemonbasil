class CreateLemonDropHeroSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_hero_sections do |t|
      t.text :heading
      t.string :background_focus, null: false, default: 'center'
      t.string :text_color, null: false, default: 'light'
      t.string :min_height, null: false, default: 'tall'

      t.timestamps
    end
  end
end

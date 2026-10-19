class CreateLemonDropIntroSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_intro_sections do |t|
      t.string :heading
      t.text :body_html
      t.string :signoff

      t.timestamps
    end
  end
end

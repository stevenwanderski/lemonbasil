class CreateLemonDropOutroSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_outro_sections do |t|
      t.string :heading
      t.text :body_html
      t.string :cta_label
      t.string :cta_url

      t.timestamps
    end
  end
end

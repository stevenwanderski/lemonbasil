class CreateLemonDropTitlePageSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_title_page_sections do |t|
      t.string :heading
      t.string :tagline
      t.string :date_label

      t.timestamps
    end
  end
end

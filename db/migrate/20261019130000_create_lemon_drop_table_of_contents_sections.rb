class CreateLemonDropTableOfContentsSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_table_of_contents_sections do |t|
      t.string :heading

      t.timestamps
    end
  end
end

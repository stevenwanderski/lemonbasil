class CreateLemonDropSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_sections do |t|
      t.references :issue, null: false, foreign_key: { to_table: :lemon_drop_issues }
      t.references :sectionable, polymorphic: true, null: false
      t.integer :position, null: false, default: 0
      t.boolean :visible, null: false, default: true
      t.string :theme, null: false, default: 'cream'
      t.string :anchor, null: false
      t.boolean :show_in_toc, null: false, default: false
      t.string :toc_label

      t.timestamps
    end

    add_index :lemon_drop_sections, [:issue_id, :anchor], unique: true
    add_index :lemon_drop_sections, [:issue_id, :position]
  end
end

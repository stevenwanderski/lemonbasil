class CreateLemonDropIssues < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_issues do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :status, null: false, default: 'draft'
      t.datetime :published_at

      t.timestamps
    end

    add_index :lemon_drop_issues, :slug, unique: true
  end
end

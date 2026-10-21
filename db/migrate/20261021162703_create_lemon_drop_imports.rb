class CreateLemonDropImports < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_imports do |t|
      t.text :raw_json, null: false
      t.references :user, null: false, foreign_key: true
      t.references :issue, foreign_key: { to_table: :lemon_drop_issues }

      t.timestamps
    end
  end
end

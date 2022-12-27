class CreateStapleSelections < ActiveRecord::Migration[6.1]
  def change
    create_table :staple_selections do |t|
      t.integer :staple_id
      t.integer :client_menu_submission_id

      t.timestamps
    end
  end
end

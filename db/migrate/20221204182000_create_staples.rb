class CreateStaples < ActiveRecord::Migration[6.1]
  def change
    create_table :staples do |t|
      t.string :name
      t.integer :client_menu_id
      t.integer :weight
      t.boolean :selected, default: false

      t.timestamps
    end
  end
end

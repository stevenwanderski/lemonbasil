class AddStaplesNotesToClientMenus < ActiveRecord::Migration[6.1]
  def change
    add_column :client_menus, :staples_notes, :text
  end
end

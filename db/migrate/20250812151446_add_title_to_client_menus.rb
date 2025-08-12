class AddTitleToClientMenus < ActiveRecord::Migration[7.0]
  def change
    add_column :client_menus, :title, :string
  end
end

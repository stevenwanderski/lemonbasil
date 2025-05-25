class AddIsKatToClientMenus < ActiveRecord::Migration[7.0]
  def change
    add_column :client_menus, :is_kat, :boolean, default: false
  end
end

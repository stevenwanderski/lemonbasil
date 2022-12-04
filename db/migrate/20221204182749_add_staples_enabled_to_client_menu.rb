class AddStaplesEnabledToClientMenu < ActiveRecord::Migration[6.1]
  def change
    add_column :client_menus, :staples_enabled, :boolean, default: false
  end
end

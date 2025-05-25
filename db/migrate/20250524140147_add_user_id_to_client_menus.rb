class AddUserIdToClientMenus < ActiveRecord::Migration[7.0]
  def change
    add_column :client_menus, :user_id, :integer
  end
end

class AddAllergiesToClientMenus < ActiveRecord::Migration[7.0]
  def change
    add_column :client_menus, :allergies, :string
  end
end

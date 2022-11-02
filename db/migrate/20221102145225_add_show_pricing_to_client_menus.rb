class AddShowPricingToClientMenus < ActiveRecord::Migration[6.1]
  def change
    add_column :client_menus, :show_pricing, :boolean, default: false
  end
end

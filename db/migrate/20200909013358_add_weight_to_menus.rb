class AddWeightToMenus < ActiveRecord::Migration[6.0]
  def change
    add_column :menus, :weight, :integer
  end
end

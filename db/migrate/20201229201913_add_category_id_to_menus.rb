class AddCategoryIdToMenus < ActiveRecord::Migration[6.0]
  def change
    add_column :menus, :category_id, :integer
  end
end

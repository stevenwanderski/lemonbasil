class RemoveVisibleFromLemonDropSections < ActiveRecord::Migration[7.0]
  def change
    remove_column :lemon_drop_sections, :visible, :boolean, default: true, null: false
  end
end

class CreateLemonDropMenuOverviewSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lemon_drop_menu_overview_sections do |t|
      t.string :heading
      t.string :category_order, array: true, null: false,
        default: %w[entree soup salad snack breakfast side dessert]

      t.timestamps
    end
  end
end

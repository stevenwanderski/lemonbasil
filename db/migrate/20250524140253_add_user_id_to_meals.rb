class AddUserIdToMeals < ActiveRecord::Migration[7.0]
  def change
    add_column :meals, :user_id, :integer
  end
end

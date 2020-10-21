class ChangeEventDateColumns < ActiveRecord::Migration[6.0]
  def up
    change_column :events, :starts_at, :date
    remove_column :events, :ends_at
  end

  def down
    change_column :events, :starts_at, :datetime
    add_column :events, :ends_at, :datetime
  end
end

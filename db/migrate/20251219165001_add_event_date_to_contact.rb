class AddEventDateToContact < ActiveRecord::Migration[7.0]
  def change
    add_column :contacts, :event_date, :string
  end
end

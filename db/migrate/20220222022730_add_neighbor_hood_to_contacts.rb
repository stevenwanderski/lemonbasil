class AddNeighborHoodToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :neighborhood, :string
  end
end

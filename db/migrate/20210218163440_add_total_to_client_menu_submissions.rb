class AddTotalToClientMenuSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :client_menu_submissions, :total, :integer
  end
end

class AddNotesToClientMenuSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :client_menu_submissions, :notes, :text
  end
end

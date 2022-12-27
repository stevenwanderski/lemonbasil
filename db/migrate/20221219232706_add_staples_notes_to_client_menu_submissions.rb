class AddStaplesNotesToClientMenuSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :client_menu_submissions, :staples_notes, :text
  end
end

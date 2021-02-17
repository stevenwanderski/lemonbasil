class AddJobDateToClientMenus < ActiveRecord::Migration[6.0]
  def change
    add_column :client_menus, :job_date, :datetime
  end
end

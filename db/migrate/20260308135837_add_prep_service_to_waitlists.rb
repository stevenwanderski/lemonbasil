class AddPrepServiceToWaitlists < ActiveRecord::Migration[7.0]
  def change
    add_column :waitlists, :prep_service, :string
  end
end

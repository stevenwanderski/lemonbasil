class CreateWaitlists < ActiveRecord::Migration[7.0]
  def change
    create_table :waitlists do |t|
      t.string :name
      t.string :email
      t.string :neighborhood
      t.string :start_date
      t.text :message

      t.timestamps
    end
  end
end

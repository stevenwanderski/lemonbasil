class CreateClientMenuMailerLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :client_menu_mailer_logs do |t|
      t.integer :client_menu_id
      t.string :email
      t.datetime :sent_at

      t.timestamps
    end
  end
end

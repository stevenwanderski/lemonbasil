class CreateJobApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :job_applications do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :position
      t.text :message

      t.timestamps
    end
  end
end

# == Schema Information
#
# Table name: contacts
#
#  id           :bigint           not null, primary key
#  email        :string           not null
#  message      :text
#  name         :string           not null
#  neighborhood :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Contact < ApplicationRecord
  validates :name, :email, :message, presence: true

  EMAIL_BLOCKLIST = [
    'no-replyhat@gmail.com'
  ]

  def self.valid_email?(email)
    !EMAIL_BLOCKLIST.include?(email.downcase)
  end
end

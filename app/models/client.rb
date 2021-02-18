# == Schema Information
#
# Table name: clients
#
#  id         :bigint           not null, primary key
#  email      :string
#  first_name :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Client < ApplicationRecord
  validates_presence_of :email

  def full_name
    "#{first_name} #{last_name}"
  end
end

# == Schema Information
#
# Table name: clients
#
#  id         :bigint           not null, primary key
#  first_name :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Client < ApplicationRecord
  def full_name
    "#{first_name} #{last_name}"
  end
end

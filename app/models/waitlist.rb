# == Schema Information
#
# Table name: waitlists
#
#  id           :bigint           not null, primary key
#  email        :string
#  message      :text
#  name         :string
#  neighborhood :string
#  start_date   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Waitlist < ApplicationRecord
end

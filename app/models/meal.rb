# == Schema Information
#
# Table name: meals
#
#  id           :bigint           not null, primary key
#  instructions :text
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#
class Meal < ApplicationRecord
  belongs_to :user
end

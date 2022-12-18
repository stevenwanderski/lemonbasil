# == Schema Information
#
# Table name: staple_categories
#
#  id             :bigint           not null, primary key
#  name           :string
#  weight         :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_menu_id :integer
#  staple_id      :integer
#
class StapleCategory < ApplicationRecord
  has_many :staples
end

# == Schema Information
#
# Table name: staples
#
#  id             :bigint           not null, primary key
#  name           :string
#  selected       :boolean          default(FALSE)
#  weight         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_menu_id :integer
#
class Staple < ApplicationRecord
  belongs_to :client_menu
end

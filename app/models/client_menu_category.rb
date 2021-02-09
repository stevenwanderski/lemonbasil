# == Schema Information
#
# Table name: client_menu_categories
#
#  id             :bigint           not null, primary key
#  description    :text
#  name           :string
#  weight         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_menu_id :integer
#
class ClientMenuCategory < ApplicationRecord
  belongs_to :client_menu
end

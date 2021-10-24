# == Schema Information
#
# Table name: client_menu_selections
#
#  id                        :bigint           not null, primary key
#  message                   :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  client_menu_item_id       :integer
#  client_menu_submission_id :integer
#
class ClientMenuSelection < ApplicationRecord
  belongs_to :client_menu_submission
  belongs_to :client_menu_item
  has_one :instruction

  accepts_nested_attributes_for :instruction
end

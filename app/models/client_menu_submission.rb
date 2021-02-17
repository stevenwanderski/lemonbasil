# == Schema Information
#
# Table name: client_menu_submissions
#
#  id             :bigint           not null, primary key
#  message        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_menu_id :integer
#
class ClientMenuSubmission < ApplicationRecord
  has_many :client_menu_selections
end

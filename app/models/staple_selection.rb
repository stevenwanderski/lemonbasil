# == Schema Information
#
# Table name: staple_selections
#
#  id                        :bigint           not null, primary key
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  client_menu_submission_id :integer
#  staple_id                 :integer
#
class StapleSelection < ApplicationRecord
  belongs_to :staple
  belongs_to :client_menu_submission
end

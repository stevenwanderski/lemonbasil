# == Schema Information
#
# Table name: instructions
#
#  id                       :bigint           not null, primary key
#  text                     :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  client_menu_selection_id :integer          not null
#
class Instruction < ApplicationRecord
  belongs_to :client_menu_selection
end

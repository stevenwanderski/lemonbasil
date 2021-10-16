# == Schema Information
#
# Table name: client_menu_submissions
#
#  id             :bigint           not null, primary key
#  message        :text
#  total          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_menu_id :integer
#
class ClientMenuSubmission < ApplicationRecord
  belongs_to :client_menu
  has_many :client_menu_selections
  has_many :client_menu_items, through: :client_menu_selections

  def categories
    client_menu_selections.map do |selection|
      selection
        .client_menu_item
        .client_menu_category
    end.uniq
  end

  def items(category)
    client_menu_selections.filter do |selection|
      selection.client_menu_item.client_menu_category_id == category.id
    end.map(&:client_menu_item)
  end
end

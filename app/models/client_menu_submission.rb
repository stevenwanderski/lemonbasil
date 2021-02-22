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
  has_many :client_menu_selections
  belongs_to :client_menu

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

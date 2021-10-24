# == Schema Information
#
# Table name: client_menu_submissions
#
#  id             :bigint           not null, primary key
#  message        :text
#  notes          :text
#  total          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_menu_id :integer
#
class ClientMenuSubmission < ApplicationRecord
  belongs_to :client_menu
  has_many :client_menu_selections
  has_many :client_menu_items, through: :client_menu_selections

  before_save :set_total

  def running_total
    client_menu_items.inject(0) { |sum, item| sum + item.cost.to_i }
  end

  def running_quantity
    client_menu_items.size
  end

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
    end
  end

  private

  def set_total
    return if self.total.present?

    self.total = self.running_total
  end
end

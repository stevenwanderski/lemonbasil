# == Schema Information
#
# Table name: client_menus
#
#  id         :bigint           not null, primary key
#  due_at     :datetime
#  job_date   :datetime
#  message    :text
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :integer
#
class ClientMenu < ApplicationRecord
  belongs_to :client
  has_many :client_menu_categories
  has_many :client_menu_items, through: :client_menu_categories
  has_many :client_menu_submissions

  before_create :set_slug

  def duplicate!(new_values = {})
    menu = self.deep_clone include: [{ client_menu_categories: :client_menu_items }]
    menu.assign_attributes(new_values)
    menu.save!
    menu
  end

  def newest_submission
    client_menu_submissions.order(created_at: :desc).first
  end

  def set_slug
    self.slug = loop do
      random_short_code = ('a'..'z').to_a.shuffle[0,6].join
      break random_short_code unless ClientMenu.exists?(slug: random_short_code)
    end
  end
end

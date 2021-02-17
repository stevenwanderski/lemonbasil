# == Schema Information
#
# Table name: client_menus
#
#  id         :bigint           not null, primary key
#  due_at     :datetime
#  message    :text
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :integer
#
class ClientMenu < ApplicationRecord
  belongs_to :client
  has_many :client_menu_categories
  has_one :client_menu_submission

  before_create :set_slug

  def set_slug
    self.slug = loop do
      random_short_code = ('a'..'z').to_a.shuffle[0,6].join
      break random_short_code unless ClientMenu.exists?(slug: random_short_code)
    end
  end
end

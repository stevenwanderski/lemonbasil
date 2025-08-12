# == Schema Information
#
# Table name: client_menus
#
#  id              :bigint           not null, primary key
#  due_at          :datetime
#  is_kat          :boolean          default(FALSE)
#  job_date        :datetime
#  message         :text
#  show_pricing    :boolean          default(FALSE)
#  slug            :string
#  staples_enabled :boolean          default(FALSE)
#  staples_notes   :text
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :integer
#  user_id         :integer
#
class ClientMenu < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :user
  has_many :client_menu_categories
  has_many :client_menu_items, through: :client_menu_categories
  has_many :client_menu_submissions
  has_many :staple_categories
  has_many :staples, through: :staple_categories
  has_many :client_menu_mailer_logs

  accepts_nested_attributes_for :staples

  before_create :set_slug

  def duplicate!(new_values = {})
    menu = self.deep_clone include: [
      { client_menu_categories: :client_menu_items },
      { staple_categories: :staples }
    ]
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

# == Schema Information
#
# Table name: lemon_drop_intro_sections
#
#  id         :bigint           not null, primary key
#  body_html  :text
#  heading    :string
#  signoff    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LemonDrop::IntroSection < ApplicationRecord
  include LemonDrop::Sectionable

  has_one_attached :icon do |attachable|
    attachable.variant :icon, resize_to_limit: [600, 600], saver: { strip: true }
  end

  validates :icon,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }
end

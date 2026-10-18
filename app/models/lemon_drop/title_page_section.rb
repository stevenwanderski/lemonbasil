# == Schema Information
#
# Table name: lemon_drop_title_page_sections
#
#  id         :bigint           not null, primary key
#  date_label :string
#  heading    :string
#  tagline    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LemonDrop::TitlePageSection < ApplicationRecord
  include LemonDrop::Sectionable

  has_one_attached :cover_image do |attachable|
    attachable.variant :cover, resize_to_limit: [1600, 1600], saver: { strip: true }
  end

  validates :cover_image,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }

  def display_date_label
    date_label.presence || section&.issue&.date_label
  end
end

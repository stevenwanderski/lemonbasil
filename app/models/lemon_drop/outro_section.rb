# == Schema Information
#
# Table name: lemon_drop_outro_sections
#
#  id         :bigint           not null, primary key
#  body_html  :text
#  cta_label  :string
#  cta_url    :string
#  heading    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LemonDrop::OutroSection < ApplicationRecord
  include LemonDrop::Sectionable

  before_save { self.body_html = LemonDrop::RichText.sanitize(body_html) if body_html_changed? }

  has_many_attached :images do |attachable|
    attachable.variant :grid, resize_to_limit: [800, 800], saver: { strip: true }
  end

  validates :images,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes },
    limit: { max: 6 }
  validates :cta_url, format: { with: %r{\A(https://|mailto:)\S+\z}, message: 'must start with https:// or mailto:' },
    allow_blank: true
  validates :cta_label, presence: true, if: -> { cta_url.present? }
end

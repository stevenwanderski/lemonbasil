class LemonDrop::HeroSection < ApplicationRecord
  include LemonDrop::Sectionable

  has_one_attached :background_image do |attachable|
    attachable.variant :background, resize_to_limit: [1600, 1600], saver: { strip: true }
  end
  has_one_attached :overlay_image do |attachable|
    attachable.variant :overlay, resize_to_limit: [600, 600], saver: { strip: true }
  end

  enum background_focus: { top: 'top', center: 'center', bottom: 'bottom' }, _prefix: :focus
  enum text_color: { light: 'light', dark: 'dark' }, _prefix: :text
  enum min_height: { medium: 'medium', tall: 'tall' }, _prefix: :height

  validates :background_image, :overlay_image,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }

  # One line of large text per line of the heading ("let's" / "cook").
  def heading_lines
    heading.to_s.lines.map(&:strip).reject(&:blank?)
  end
end

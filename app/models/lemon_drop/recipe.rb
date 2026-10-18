class LemonDrop::Recipe < ApplicationRecord
  belongs_to :recipes_section
  has_one :section, through: :recipes_section
  has_one :issue, through: :section
  has_many :ingredient_groups, -> { order(:position) }, dependent: :destroy
  has_many :steps, -> { order(:position) }, dependent: :destroy

  has_one_attached :hero_image do |attachable|
    attachable.variant :hero, resize_to_limit: [1600, 1600], saver: { strip: true }
  end

  enum category: {
    entree: 'entree', soup: 'soup', salad: 'salad', snack: 'snack',
    breakfast: 'breakfast', side: 'side', dessert: 'dessert'
  }
  enum hero_focus: { top: 'top', center: 'center', bottom: 'bottom' }, _prefix: :focus

  before_validation :set_default_slug

  validates :title, :slug, presence: true
  validate :slug_unique_within_issue
  validates :hero_image,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }

  # "prep time: 15 mins + marinating / cook time: 40 mins / total time: 1hr /
  # serves: 5", leaving out any part without a value.
  def time_line
    parts = []
    parts << "prep time: #{[duration_label(prep_minutes), time_note.presence].compact.join(' ')}" if prep_minutes
    parts << "cook time: #{duration_label(cook_minutes)}" if cook_minutes
    parts << "total time: #{total_time_label}" if total_time_label
    parts << "serves: #{serves}" if serves
    parts.join(' / ').presence
  end

  def total_time_label
    return total_label if total_label.present?
    return if prep_minutes.nil? && cook_minutes.nil?

    duration_label(prep_minutes.to_i + cook_minutes.to_i)
  end

  private

  # "45 mins", "1 hour", "1 hour 20 mins", "2 hours".
  def duration_label(minutes)
    hours, mins = minutes.divmod(60)
    [
      ("#{hours} #{'hour'.pluralize(hours)}" if hours.positive?),
      ("#{mins} #{'min'.pluralize(mins)}" if mins.positive? || hours.zero?)
    ].compact.join(' ')
  end

  # Defaults from the title ("chickpea-stew"), with a number added when the
  # Issue already uses it as a Recipe slug or Section anchor ("chickpea-stew-2").
  def set_default_slug
    return if slug.present? || title.blank?

    self.slug = issue ? LemonDrop.unique_page_id(title.parameterize, issue.taken_page_ids(except: self)) : title.parameterize
  end

  def slug_unique_within_issue
    return if slug.blank? || issue.nil?

    errors.add(:slug, :taken) if issue.taken_page_ids(except: self).include?(slug)
  end
end

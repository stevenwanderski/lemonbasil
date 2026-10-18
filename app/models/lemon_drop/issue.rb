# == Schema Information
#
# Table name: lemon_drop_issues
#
#  id           :bigint           not null, primary key
#  ends_on      :date             not null
#  published_at :datetime
#  slug         :string           not null
#  starts_on    :date             not null
#  status       :string           default("draft"), not null
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_lemon_drop_issues_on_slug  (slug) UNIQUE
#
class LemonDrop::Issue < ApplicationRecord
  has_many :sections, -> { order(:position) }, dependent: :destroy
  has_many :recipes_sections, through: :sections, source: :sectionable, source_type: 'LemonDrop::RecipesSection'
  # Every Recipe in the Issue, in page order: Section position, then Recipe
  # position.
  has_many :recipes, -> { reorder('lemon_drop_sections.position', 'lemon_drop_recipes.position') },
    through: :recipes_sections

  enum status: { draft: 'draft', published: 'published' }

  before_validation :set_default_slug

  validates :title, :slug, :starts_on, :ends_on, presence: true
  validates :slug, uniqueness: true
  validate :ends_on_not_before_starts_on

  # Section anchors and Recipe slugs share the page's id space. Leaves out
  # the record asking, so it doesn't collide with itself.
  def taken_page_ids(except: nil)
    other_sections = except.is_a?(LemonDrop::Section) ? sections.excluding(except) : sections
    other_recipes = except.is_a?(LemonDrop::Recipe) ? recipes.excluding(except) : recipes
    other_sections.pluck(:anchor) + other_recipes.pluck(:slug)
  end

  # "oct 19–23", or "oct 30–nov 3" when the dates span two months.
  def date_label
    return if starts_on.blank? || ends_on.blank?

    start = starts_on.strftime('%b %-d').downcase
    return start if starts_on == ends_on

    finish = starts_on.month == ends_on.month ? ends_on.day.to_s : ends_on.strftime('%b %-d').downcase
    "#{start}–#{finish}"
  end

  # The date in the page footer: the first visible Title Page's, or the Issue's.
  def footer_date_label
    title_page = sections.visible.lemon_drop_title_page_sections.first&.sectionable
    title_page&.display_date_label || date_label
  end

  private

  def set_default_slug
    self.slug = starts_on.iso8601 if slug.blank? && starts_on.present?
  end

  def ends_on_not_before_starts_on
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "can't be before the start date") if ends_on < starts_on
  end
end

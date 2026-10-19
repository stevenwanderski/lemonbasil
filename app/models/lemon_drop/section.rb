# == Schema Information
#
# Table name: lemon_drop_sections
#
#  id               :bigint           not null, primary key
#  anchor           :string           not null
#  position         :integer          default(0), not null
#  sectionable_type :string           not null
#  show_in_toc      :boolean          default(FALSE), not null
#  theme            :string           default("cream"), not null
#  toc_label        :string
#  visible          :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  issue_id         :bigint           not null
#  sectionable_id   :bigint           not null
#
# Indexes
#
#  index_lemon_drop_sections_on_issue_id               (issue_id)
#  index_lemon_drop_sections_on_issue_id_and_anchor    (issue_id,anchor) UNIQUE
#  index_lemon_drop_sections_on_issue_id_and_position  (issue_id,position)
#  index_lemon_drop_sections_on_sectionable            (sectionable_type,sectionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (issue_id => lemon_drop_issues.id)
#
class LemonDrop::Section < ApplicationRecord
  TYPES = %w[
    LemonDrop::TitlePageSection
    LemonDrop::IntroSection
    LemonDrop::TableOfContentsSection
    LemonDrop::HeroSection
    LemonDrop::MenuOverviewSection
    LemonDrop::RecipesSection
    LemonDrop::GroceryListSection
    LemonDrop::AllergenSwapSection
    LemonDrop::OutroSection
  ].freeze

  belongs_to :issue
  delegated_type :sectionable, types: TYPES, dependent: :destroy

  enum theme: { cream: 'cream', sage: 'sage' }, _prefix: true

  scope :visible, -> { where(visible: true) }

  before_validation :set_default_anchor

  validates :anchor, presence: true, uniqueness: { scope: :issue_id }
  validate :anchor_not_a_recipe_slug

  # The Table of Contents entry: the TOC label, or else the Section heading.
  def display_toc_label
    toc_label.presence || sectionable.heading.to_s.squish
  end

  private

  # Defaults from the Section type ("title-page"), with a number added when
  # the Issue already uses it as an anchor or Recipe slug ("title-page-2").
  def set_default_anchor
    return if anchor.present? || issue.nil? || sectionable.nil?

    base = sectionable.model_name.element.delete_suffix('_section').dasherize
    self.anchor = LemonDrop.unique_page_id(base, issue.taken_page_ids(except: self))
  end

  def anchor_not_a_recipe_slug
    return if anchor.blank? || issue.nil?

    errors.add(:anchor, :taken) if issue.recipes.exists?(slug: anchor)
  end
end

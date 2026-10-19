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

  # What a duplicate copies along with each Section type's own fields.
  DUPLICATED_CHILDREN = {
    'LemonDrop::RecipesSection' => { recipes: [:steps, { ingredient_groups: :ingredients }] },
    'LemonDrop::GroceryListSection' => { grocery_groups: :grocery_items },
    'LemonDrop::AllergenSwapSection' => [{ swap_groups: :swaps }, :swap_recipes]
  }.freeze

  belongs_to :issue
  delegated_type :sectionable, types: TYPES, dependent: :destroy
  # The Section form saves the type's own fields along with the shared ones.
  accepts_nested_attributes_for :sectionable, update_only: true

  enum theme: { cream: 'cream', sage: 'sage' }, _prefix: true

  before_validation :set_default_anchor

  validates :anchor, presence: true, uniqueness: { scope: :issue_id }
  validate :anchor_not_a_recipe_slug

  # A copy right after this Section, with its own copy of everything in it.
  # Images are copied, not shared, so deleting or replacing one never
  # touches the other. The anchor and any Recipe slugs get fresh defaults.
  def duplicate
    taken = issue.taken_page_ids
    copy = sectionable.deep_clone(include: DUPLICATED_CHILDREN.fetch(sectionable_type, [])) do |original, clone|
      LemonDrop.copy_attachments(original, clone)
      clone.slug = LemonDrop.unique_page_id(original.slug, taken).tap { |slug| taken << slug } if clone.is_a?(LemonDrop::Recipe)
    end

    issue.insert_section(copy, position: position + 1, **slice(:theme, :show_in_toc, :toc_label).symbolize_keys)
  end

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

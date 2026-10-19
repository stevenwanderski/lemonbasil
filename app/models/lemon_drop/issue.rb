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
  before_destroy :ensure_draft, prepend: true

  validates :title, :slug, :starts_on, :ends_on, presence: true
  validates :slug, uniqueness: true
  validate :ends_on_not_before_starts_on
  validate :slug_unchanged_once_published

  # "New issue" starts from the reference layout (lemon-drop/index.html): the
  # nine Section types in order, with its headings, anchors, themes and Table
  # of Contents entries. Built in memory, so they save with the Issue.
  def build_default_sections
    [
      [LemonDrop::TitlePageSection.new(heading: 'the lemon drop', tagline: 'your weekly meal plan'), { anchor: 'title-page' }],
      [LemonDrop::IntroSection.new(heading: 'hello!'), { anchor: 'intro' }],
      [LemonDrop::TableOfContentsSection.new(heading: 'this week’s drop'), { anchor: 'table-of-contents' }],
      [LemonDrop::HeroSection.new(heading: "let’s\ncook"), { anchor: 'hero' }],
      [LemonDrop::MenuOverviewSection.new(heading: 'your menu'), { anchor: 'menu', show_in_toc: true, toc_label: 'recipes' }],
      [LemonDrop::RecipesSection.new, { anchor: 'recipes' }],
      [LemonDrop::GroceryListSection.new(heading: 'your grocery list'),
       { anchor: 'grocery', theme: 'sage', show_in_toc: true, toc_label: 'grocery list' }],
      [LemonDrop::AllergenSwapSection.new(heading: "allergen\nswaps"),
       { anchor: 'swaps', theme: 'sage', show_in_toc: true, toc_label: 'allergen swaps' }],
      [LemonDrop::OutroSection.new, { anchor: 'party' }]
    ].each.with_index(1) do |(sectionable, attributes), position|
      sections.build(sectionable: sectionable, position: position, **attributes)
    end
  end

  # Adds a Section at position (1 is the top), moving the rest down one.
  def insert_section(sectionable, position:, **attributes)
    with_lock do
      section = sections.create!(sectionable: sectionable, position: 0, **attributes)
      ids = sections.excluding(section).ids
      ids.insert(position.to_i.clamp(1, ids.size + 1) - 1, section.id)
      reorder_sections(ids)
      section
    end
  end

  # Deletes a Section and closes the gap it leaves. A Recipes Section's
  # Recipes go with it, unless move_recipes_to names another of the Issue's
  # Recipes Sections to move them to, in their order, at its end.
  def remove_section(section, move_recipes_to: nil)
    with_lock do
      section.sectionable.recipes.to_a.each { |recipe| recipe.move_to(move_recipes_to) } if move_recipes_to
      section.reload.destroy!
      reorder_sections(sections.ids)
    end
  end

  # Stores the order given, as every one of the Issue's Section ids top
  # first, in position: 1, 2, 3…
  def reorder_sections(ids)
    ids = ids.map(&:to_i)
    with_lock do
      raise ArgumentError, 'not exactly this Issue’s Sections' unless ids.sort == sections.ids.sort

      ids.each.with_index(1) { |id, position| sections.where(id: id).update_all(position: position) }
    end
  end

  # What readers see, in page order; the preview shows exactly the same.
  # Every Section, less any with nothing to show (a Menu Overview with no
  # Recipes).
  def page_sections
    sections.includes(:sectionable).reject { |section| section.sectionable.skipped? }
  end

  # The first-published time is set once and kept through any later
  # unpublishing and republishing.
  def publish!
    update!(status: 'published', published_at: published_at || Time.current)
  end

  def unpublish!
    update!(status: 'draft')
  end

  # Shared links never break: the slug is fixed from the first publish on,
  # even if the Issue goes back to Draft.
  def slug_locked?
    published_at_in_database.present?
  end

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

  # The date in the page footer: the first Title Page's, or the Issue's.
  def footer_date_label
    title_page = sections.lemon_drop_title_page_sections.first&.sectionable
    title_page&.display_date_label || date_label
  end

  private

  def set_default_slug
    self.slug = starts_on.iso8601 if slug.blank? && starts_on.present?
  end

  # A Published Issue must be unpublished before it can be deleted.
  def ensure_draft
    return if draft?

    errors.add(:base, 'Unpublish this Issue before deleting it')
    throw :abort
  end

  def slug_unchanged_once_published
    errors.add(:slug, "can't be changed once the Issue has been published") if slug_changed? && slug_locked?
  end

  def ends_on_not_before_starts_on
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "can't be before the start date") if ends_on < starts_on
  end
end

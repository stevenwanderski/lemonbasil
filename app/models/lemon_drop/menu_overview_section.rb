# == Schema Information
#
# Table name: lemon_drop_menu_overview_sections
#
#  id             :bigint           not null, primary key
#  category_order :string           default(["\"entree\"", "\"soup\"", "\"salad\"", "\"snack\"", "\"breakfast\"", "\"side\"", "\"dessert\""]), not null, is an Array
#  heading        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class LemonDrop::MenuOverviewSection < ApplicationRecord
  include LemonDrop::Sectionable

  CATEGORY_LABELS = {
    'entree' => 'entrees', 'soup' => 'soup', 'salad' => 'salad', 'snack' => 'snack',
    'breakfast' => 'breakfast', 'side' => 'sides', 'dessert' => 'dessert'
  }.freeze

  has_one_attached :icon do |attachable|
    attachable.variant :icon, resize_to_limit: [600, 600], saver: { strip: true }
  end

  validates :icon,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }
  validate :category_order_holds_recipe_categories

  # Every Recipe category in this menu's order; any it leaves out go last.
  def full_category_order
    (category_order + LemonDrop::Recipe.categories.keys).uniq
  end

  # Built from the page itself: every Recipe in the Issue's visible Recipes
  # Sections, as [category, recipes] pairs in category order, leaving out
  # empty categories.
  def categories
    @categories ||= begin
      recipes = section.issue.visible_recipes.group_by(&:category)
      full_category_order.filter_map do |category|
        [category, recipes[category]] if recipes[category]
      end
    end
  end

  def skipped?
    categories.empty?
  end

  # The categories in the reference's two columns, as even as they'll go.
  def columns
    LemonDrop.balanced_columns(categories, 2) { |_, recipes| recipes.size }
  end

  private

  def category_order_holds_recipe_categories
    return if category_order.uniq == category_order && (category_order - LemonDrop::Recipe.categories.keys).empty?

    errors.add(:category_order, 'can only hold the Recipe categories, once each')
  end
end

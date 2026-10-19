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

  # Built from the page itself: every Recipe in the Issue's visible Recipes
  # Sections, as [category, recipes] pairs in category order, leaving out
  # empty categories. Any category missing from the order goes last.
  def categories
    @categories ||= begin
      recipes = section.issue.visible_recipes.group_by(&:category)
      (category_order + LemonDrop::Recipe.categories.keys).uniq.filter_map do |category|
        [category, recipes[category]] if recipes[category]
      end
    end
  end

  def skipped?
    categories.empty?
  end

  # The categories split into two columns, keeping their order, at the point
  # where the columns' Recipe counts come out most even.
  def columns
    return [categories] if categories.size < 2

    split = (1...categories.size).min_by do |index|
      [categories.first(index), categories.drop(index)].map { |column| column.sum { |_, recipes| recipes.size } }.max
    end
    [categories.first(split), categories.drop(split)]
  end
end

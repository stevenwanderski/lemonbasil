# == Schema Information
#
# Table name: lemon_drop_ingredient_groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  position   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  recipe_id  :bigint           not null
#
# Indexes
#
#  index_lemon_drop_ingredient_groups_on_recipe_id  (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_id => lemon_drop_recipes.id)
#
class LemonDrop::IngredientGroup < ApplicationRecord
  belongs_to :recipe
  has_many :ingredients, -> { order(:position) }, dependent: :destroy, autosave: true

  # The ingredients as the form edits them: one per line, top first.
  def ingredients_text
    ingredients.reject(&:marked_for_destruction?).map(&:text).join("\n")
  end

  # Replaces the ingredients with one per line, in order, when saved. Each
  # line is kept as written, only trimmed; blank lines are skipped.
  def ingredients_text=(text)
    lines = LemonDrop.lines(text)
    return if lines == LemonDrop.lines(ingredients_text)

    ingredients.each(&:mark_for_destruction)
    lines.each.with_index(1) { |line, position| ingredients.build(text: line, position: position) }
  end
end

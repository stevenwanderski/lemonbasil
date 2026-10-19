# == Schema Information
#
# Table name: lemon_drop_recipes_sections
#
#  id         :bigint           not null, primary key
#  heading    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LemonDrop::RecipesSection < ApplicationRecord
  include LemonDrop::Sectionable

  has_many :recipes, -> { order(:position) }, dependent: :destroy

  # A new Recipe at the end of this Section.
  def build_recipe(attributes = {})
    recipes.build(position: recipes.maximum(:position).to_i + 1, **attributes)
  end

  # Stores the order given, as every one of this Section's Recipe ids top
  # first, in position: 1, 2, 3…
  def reorder_recipes(ids)
    ids = ids.map(&:to_i)
    with_lock do
      raise ArgumentError, 'not exactly this Section’s Recipes' unless ids.sort == recipes.ids.sort

      ids.each.with_index(1) { |id, position| recipes.where(id: id).update_all(position: position) }
    end
  end

  # Closes any gap a Recipe leaving has left: 1, 2, 3… in the current order.
  def renumber_recipes
    reorder_recipes(recipes.reload.ids)
  end
end

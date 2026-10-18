# == Schema Information
#
# Table name: lemon_drop_swap_recipes
#
#  id                       :bigint           not null, primary key
#  ingredients              :text
#  position                 :integer          default(0), not null
#  steps                    :text
#  title                    :string           not null
#  use_for                  :string
#  yield_label              :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  allergen_swap_section_id :bigint           not null
#
# Indexes
#
#  index_lemon_drop_swap_recipes_on_allergen_swap_section_id  (allergen_swap_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (allergen_swap_section_id => lemon_drop_allergen_swap_sections.id)
#
# A small companion recipe (cashew ricotta) inside an Allergen Swap Section.
# Not a Recipe: it has no page of its own and never appears on the menu.
class LemonDrop::SwapRecipe < ApplicationRecord
  belongs_to :allergen_swap_section

  validates :title, presence: true

  def ingredient_lines
    ingredients.to_s.lines.map(&:strip).reject(&:blank?)
  end

  def step_lines
    steps.to_s.lines.map(&:strip).reject(&:blank?)
  end
end

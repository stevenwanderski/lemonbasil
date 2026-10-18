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
  has_many :ingredients, -> { order(:position) }, dependent: :destroy
end

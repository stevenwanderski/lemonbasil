# == Schema Information
#
# Table name: lemon_drop_ingredients
#
#  id                  :bigint           not null, primary key
#  position            :integer          default(0), not null
#  text                :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  ingredient_group_id :bigint           not null
#
# Indexes
#
#  index_lemon_drop_ingredients_on_ingredient_group_id  (ingredient_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_group_id => lemon_drop_ingredient_groups.id)
#
# Free text, kept exactly as written ("2 cans chickpeas (15 oz each), drained
# and rinsed"). Quantities are never parsed.
class LemonDrop::Ingredient < ApplicationRecord
  belongs_to :ingredient_group

  validates :text, presence: true
end

# Free text, kept exactly as written ("2 cans chickpeas (15 oz each), drained
# and rinsed"). Quantities are never parsed.
class LemonDrop::Ingredient < ApplicationRecord
  belongs_to :ingredient_group

  validates :text, presence: true
end

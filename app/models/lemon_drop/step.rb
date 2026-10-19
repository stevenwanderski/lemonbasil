# == Schema Information
#
# Table name: lemon_drop_steps
#
#  id         :bigint           not null, primary key
#  body       :text             not null
#  position   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  recipe_id  :bigint           not null
#
# Indexes
#
#  index_lemon_drop_steps_on_recipe_id  (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_id => lemon_drop_recipes.id)
#
class LemonDrop::Step < ApplicationRecord
  belongs_to :recipe

  validates :body, presence: true
end

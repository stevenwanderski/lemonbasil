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
end

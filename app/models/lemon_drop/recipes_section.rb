class LemonDrop::RecipesSection < ApplicationRecord
  include LemonDrop::Sectionable

  has_many :recipes, -> { order(:position) }, dependent: :destroy
end

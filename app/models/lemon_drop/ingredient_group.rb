class LemonDrop::IngredientGroup < ApplicationRecord
  belongs_to :recipe
  has_many :ingredients, -> { order(:position) }, dependent: :destroy
end

# == Schema Information
#
# Table name: lemon_drop_swap_groups
#
#  id                       :bigint           not null, primary key
#  name                     :string
#  position                 :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  allergen_swap_section_id :bigint           not null
#
# Indexes
#
#  index_lemon_drop_swap_groups_on_allergen_swap_section_id  (allergen_swap_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (allergen_swap_section_id => lemon_drop_allergen_swap_sections.id)
#
class LemonDrop::SwapGroup < ApplicationRecord
  belongs_to :allergen_swap_section
  has_many :swaps, -> { order(:position) }, dependent: :destroy
end

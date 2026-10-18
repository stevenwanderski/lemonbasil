# == Schema Information
#
# Table name: lemon_drop_grocery_groups
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  position                :integer          default(0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  grocery_list_section_id :bigint           not null
#
# Indexes
#
#  index_lemon_drop_grocery_groups_on_grocery_list_section_id  (grocery_list_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (grocery_list_section_id => lemon_drop_grocery_list_sections.id)
#
class LemonDrop::GroceryGroup < ApplicationRecord
  belongs_to :grocery_list_section
  has_many :grocery_items, -> { order(:position) }, dependent: :destroy
end

# == Schema Information
#
# Table name: lemon_drop_grocery_items
#
#  id               :bigint           not null, primary key
#  position         :integer          default(0), not null
#  text             :text             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  grocery_group_id :bigint           not null
#
# Indexes
#
#  index_lemon_drop_grocery_items_on_grocery_group_id  (grocery_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (grocery_group_id => lemon_drop_grocery_groups.id)
#
class LemonDrop::GroceryItem < ApplicationRecord
  belongs_to :grocery_group

  validates :text, presence: true
end

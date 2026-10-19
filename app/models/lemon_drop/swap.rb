# == Schema Information
#
# Table name: lemon_drop_swaps
#
#  id            :bigint           not null, primary key
#  from_text     :string           not null
#  position      :integer          default(0), not null
#  to_text       :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  swap_group_id :bigint           not null
#
# Indexes
#
#  index_lemon_drop_swaps_on_swap_group_id  (swap_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (swap_group_id => lemon_drop_swap_groups.id)
#
class LemonDrop::Swap < ApplicationRecord
  belongs_to :swap_group

  validates :from_text, :to_text, presence: true
end

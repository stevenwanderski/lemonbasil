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
  has_many :grocery_items, -> { order(:position) }, dependent: :destroy, autosave: true

  # The items as the form edits them: one per line, top first.
  def items_text
    grocery_items.reject(&:marked_for_destruction?).map(&:text).join("\n")
  end

  # Replaces the items with one per line, in order, when saved.
  def items_text=(text)
    lines = LemonDrop.lines(text)
    return if lines == LemonDrop.lines(items_text)

    grocery_items.each(&:mark_for_destruction)
    lines.each.with_index(1) { |line, position| grocery_items.build(text: line, position: position) }
  end
end

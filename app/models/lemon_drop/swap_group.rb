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
  has_many :swaps, -> { order(:position) }, dependent: :destroy, autosave: true

  ARROW = /\s*(?:→|->)\s*/

  validate :swap_lines_have_arrows

  # The swaps as the form edits them: one "from → to" per line, top first.
  # After a refused save it gives back exactly what was typed.
  def swaps_text
    @swaps_text || swaps.reject(&:marked_for_destruction?).map { |swap| "#{swap.from_text} → #{swap.to_text}" }.join("\n")
  end

  # Replaces the swaps with one per line, written "from → to" or "from -> to".
  def swaps_text=(text)
    # Numbered as the textarea shows them, blank lines included.
    pairs = []
    @lines_without_arrows = []
    text.to_s.lines.map(&:strip).each.with_index(1) do |line, number|
      next if line.blank?

      from, to = line.split(ARROW, 2)
      from.present? && to.present? ? pairs << [from, to] : @lines_without_arrows << [number, line]
    end
    @swaps_text = text if @lines_without_arrows.any?
    return if pairs == swaps.reject(&:marked_for_destruction?).map { |swap| [swap.from_text, swap.to_text] }

    swaps.each(&:mark_for_destruction)
    pairs.each.with_index(1) { |(from, to), position| swaps.build(from_text: from, to_text: to, position: position) }
  end

  private

  def swap_lines_have_arrows
    @lines_without_arrows.to_a.each do |number, line|
      errors.add(:base, "#{name.presence || 'A swap group'}, line #{number} (“#{line}”) needs an arrow: from → to")
    end
  end
end

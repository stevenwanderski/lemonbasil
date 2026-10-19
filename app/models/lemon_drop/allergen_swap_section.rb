# == Schema Information
#
# Table name: lemon_drop_allergen_swap_sections
#
#  id         :bigint           not null, primary key
#  disclaimer :text
#  heading    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LemonDrop::AllergenSwapSection < ApplicationRecord
  include LemonDrop::Sectionable

  DEFAULT_DISCLAIMER = 'these swaps are suggestions, not medical advice. always read labels, since ingredients ' \
                       'and how products are made can change, and check with your doctor if you have a serious allergy.'.freeze

  attribute :disclaimer, :text, default: DEFAULT_DISCLAIMER

  has_many :swap_groups, -> { order(:position) }, dependent: :destroy
  has_many :swap_recipes, -> { order(:position) }, dependent: :destroy
  # The form edits every group and swap recipe in one save; new ones left
  # empty are ignored.
  accepts_nested_attributes_for :swap_groups, allow_destroy: true,
    reject_if: ->(attributes) { attributes['id'].blank? && attributes.values_at('name', 'swaps_text').all?(&:blank?) }
  accepts_nested_attributes_for :swap_recipes, allow_destroy: true,
    reject_if: ->(attributes) { attributes['id'].blank? && attributes.except('position', '_destroy').values.all?(&:blank?) }

  has_one_attached :icon do |attachable|
    attachable.variant :icon, resize_to_limit: [600, 600], saver: { strip: true }
  end

  validates :icon,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }

  # The disclaimer always renders, even when it has been cleared.
  def display_disclaimer
    disclaimer.presence || DEFAULT_DISCLAIMER
  end
end

# == Schema Information
#
# Table name: lemon_drop_grocery_list_sections
#
#  id         :bigint           not null, primary key
#  heading    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LemonDrop::GroceryListSection < ApplicationRecord
  include LemonDrop::Sectionable

  has_many :grocery_groups, -> { order(:position) }, dependent: :destroy

  has_one_attached :icon do |attachable|
    attachable.variant :icon, resize_to_limit: [600, 600], saver: { strip: true }
  end

  validates :icon,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }

  # The groups in the reference's three columns, as even as they'll go.
  def columns
    LemonDrop.balanced_columns(grocery_groups.includes(:grocery_items).to_a, 3) { |group| group.grocery_items.size }
  end
end

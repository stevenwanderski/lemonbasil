class LemonDrop::Section < ApplicationRecord
  TYPES = %w[LemonDrop::TitlePageSection].freeze

  belongs_to :issue
  delegated_type :sectionable, types: TYPES, dependent: :destroy

  enum theme: { cream: 'cream', sage: 'sage' }, _prefix: true

  scope :visible, -> { where(visible: true) }

  before_validation :set_default_anchor

  validates :anchor, presence: true, uniqueness: { scope: :issue_id }

  private

  # Defaults from the Section type ("title-page"), with a number added when
  # the Issue already uses it ("title-page-2").
  def set_default_anchor
    return if anchor.present? || issue.nil? || sectionable.nil?

    base = sectionable.model_name.element.delete_suffix('_section').dasherize
    taken = issue.sections.where.not(id: id).pluck(:anchor)

    candidate = base
    number = 1
    candidate = "#{base}-#{number += 1}" while taken.include?(candidate)
    self.anchor = candidate
  end
end

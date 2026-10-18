# == Schema Information
#
# Table name: lemon_drop_sections
#
#  id               :bigint           not null, primary key
#  anchor           :string           not null
#  position         :integer          default(0), not null
#  sectionable_type :string           not null
#  show_in_toc      :boolean          default(FALSE), not null
#  theme            :string           default("cream"), not null
#  toc_label        :string
#  visible          :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  issue_id         :bigint           not null
#  sectionable_id   :bigint           not null
#
# Indexes
#
#  index_lemon_drop_sections_on_issue_id               (issue_id)
#  index_lemon_drop_sections_on_issue_id_and_anchor    (issue_id,anchor) UNIQUE
#  index_lemon_drop_sections_on_issue_id_and_position  (issue_id,position)
#  index_lemon_drop_sections_on_sectionable            (sectionable_type,sectionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (issue_id => lemon_drop_issues.id)
#
class LemonDrop::Section < ApplicationRecord
  TYPES = %w[
    LemonDrop::TitlePageSection
    LemonDrop::IntroSection
    LemonDrop::HeroSection
    LemonDrop::OutroSection
  ].freeze

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

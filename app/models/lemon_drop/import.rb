# == Schema Information
#
# Table name: lemon_drop_imports
#
#  id         :bigint           not null, primary key
#  raw_json   :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  issue_id   :bigint
#  user_id    :bigint           not null
#
# Indexes
#
#  index_lemon_drop_imports_on_issue_id  (issue_id)
#  index_lemon_drop_imports_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (issue_id => lemon_drop_issues.id)
#  fk_rails_...  (user_id => users.id)
#
# A week's JSON as it was pasted, kept for audit and re-running. The Issue
# it made can be deleted later (it's a Draft); the Import stays.
class LemonDrop::Import < ApplicationRecord
  belongs_to :user
  belongs_to :issue, optional: true

  validates :raw_json, presence: true
end

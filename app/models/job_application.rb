# == Schema Information
#
# Table name: job_applications
#
#  id         :bigint           not null, primary key
#  email      :string
#  message    :text
#  name       :string
#  phone      :string
#  position   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class JobApplication < ApplicationRecord
end

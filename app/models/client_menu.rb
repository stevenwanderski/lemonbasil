# == Schema Information
#
# Table name: client_menus
#
#  id         :bigint           not null, primary key
#  due_at     :datetime
#  message    :text
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :integer
#
class ClientMenu < ApplicationRecord
  belongs_to :client
end

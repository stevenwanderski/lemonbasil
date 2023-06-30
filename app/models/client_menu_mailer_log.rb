# == Schema Information
#
# Table name: client_menu_mailer_logs
#
#  id             :bigint           not null, primary key
#  email          :string
#  sent_at        :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  client_menu_id :integer
#
class ClientMenuMailerLog < ApplicationRecord
end

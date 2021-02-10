# == Schema Information
#
# Table name: client_menu_items
#
#  id                      :bigint           not null, primary key
#  cost                    :string
#  description             :text
#  name                    :string
#  quantity                :string
#  weight                  :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  client_menu_category_id :integer
#
class ClientMenuItem < ApplicationRecord
  belongs_to :client_menu_category
end

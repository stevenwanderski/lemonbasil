# == Schema Information
#
# Table name: menus
#
#  id          :bigint           not null, primary key
#  category    :string
#  description :text
#  name        :string           not null
#  weight      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Menu < ApplicationRecord
end

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
#  category_id :integer
#
class Menu < ApplicationRecord
  belongs_to :category
end

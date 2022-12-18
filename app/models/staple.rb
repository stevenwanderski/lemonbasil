# == Schema Information
#
# Table name: staples
#
#  id                 :bigint           not null, primary key
#  name               :string
#  selected           :boolean          default(FALSE)
#  weight             :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  staple_category_id :integer
#
class Staple < ApplicationRecord
  has_one :staple_category
end

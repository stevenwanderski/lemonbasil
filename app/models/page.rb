# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  body       :text
#  slug       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Page < ApplicationRecord
  def friendly_slug
    slug.gsub('-', ' ')
  end
end

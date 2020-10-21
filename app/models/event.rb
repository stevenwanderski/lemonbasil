# == Schema Information
#
# Table name: events
#
#  id         :bigint           not null, primary key
#  starts_at  :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Event < ApplicationRecord
  def self.all_dates(format: '%Y-%m-%d')
    events = Event.all.order(starts_at: :asc)

    events.map { |event| event.starts_at.strftime(format) }
  end
end

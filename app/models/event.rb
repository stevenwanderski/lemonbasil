# == Schema Information
#
# Table name: events
#
#  id         :bigint           not null, primary key
#  ends_at    :datetime
#  starts_at  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Event < ApplicationRecord
  def self.toggle!(date)
    event = find_by(starts_at: date)

    if event.present?
      return event.destroy
    end

    create!(starts_at: date, ends_at: date)
  end

  def self.all_dates(format: '%Y-%m-%d')
    events = Event.all.order(starts_at: :asc)

    events.map { |event| event.starts_at.strftime(format) }
  end
end

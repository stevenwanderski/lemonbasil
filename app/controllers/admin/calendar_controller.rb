class Admin::CalendarController < AdminController
  def index
    @event_dates = fetch_event_dates
  end

  def update
    date = params[:date]

    if event = Event.find_by(starts_at: date)
      event.destroy
    else
      Event.create!(starts_at: date, ends_at: date)
    end

    @event_dates = fetch_event_dates
  end

  private

  def fetch_event_dates
    events = Event.all.order(starts_at: :asc)

    events.map do |event|
      event.starts_at.strftime('%Y-%m-%d')
    end.to_json
  end
end

class Admin::CalendarController < AdminController
  def index
    @event_dates = Event.all_dates
  end

  def update
    Event.toggle!(params[:date])

    @event_dates = Event.all_dates
  end
end

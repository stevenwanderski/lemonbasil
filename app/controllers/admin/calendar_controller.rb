class Admin::CalendarController < AdminController
  def index
    @event_dates = Event.all_dates
    @token = ENV['API_TOKEN']
  end
end

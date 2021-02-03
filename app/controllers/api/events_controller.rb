class Api::EventsController < ApiController
  skip_before_action :authenticate_token!, only: [:index]

  def index
    format = '%Y-%m-%d'

    events = Event.all.map do |event|
      {
        title: '',
        start: event.starts_at.strftime(format),
        display: 'background'
      }
    end

    render json: events
  end

  def create
    event = Event.find_by(starts_at: params[:date])

    if event.present?
      event.destroy!
      render json: { status: 'destroyed' }, status: 204
    else
      Event.create!(starts_at: params[:date])
      render json: { status: 'created' }, status: 201
    end
  end
end

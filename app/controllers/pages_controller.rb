class PagesController < ApplicationController
  def home
  end

  def menus
    @menus = Menu.order(:category, :weight)
  end

  def calendar
    events = Event.all.order(starts_at: :asc)

    @event_dates = events.map do |event|
      event.starts_at.strftime('%Y-%m-%d')
    end.to_json
  end

  def about
    @page = Page.find_by(slug: 'about')
  end

  def meal_prep
    @page = Page.find_by(slug: 'meal-prep')
  end

  def parties
    @page = Page.find_by(slug: 'parties')
  end
end

class PagesController < ApplicationController
  def about
    @page = Page.find_by(slug: 'about')
  end

  def calendar
    @event_dates = Event.all_dates
  end

  def home
  end

  def meal_prep
    @page = Page.find_by(slug: 'meal-prep')
  end

  def menus
    @menus = Menu.order(:category, :weight)
  end

  def parties
    @page = Page.find_by(slug: 'parties')
  end
end

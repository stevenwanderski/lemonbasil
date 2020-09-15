class PagesController < ApplicationController
  def home
  end

  def about
    @page = Page.find_by(slug: 'about')
  end

  def menus
    @menus = Menu.order(:category, :weight)
  end

  def meal_prep
    @page = Page.find_by(slug: 'meal-prep')
  end

  def parties
    @page = Page.find_by(slug: 'parties')
  end
end

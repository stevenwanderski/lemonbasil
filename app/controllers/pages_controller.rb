class PagesController < ApplicationController
  def home
  end

  def about
  end

  def menus
    @menus = Menu.order(:category)
  end

  def meal_prep
  end

  def parties
  end
end

class PagesController < ApplicationController
  def home
  end

  def about
  end

  def menus
    @menus = Menu.order(:category, :weight)
  end

  def meal_prep
  end

  def parties
  end
end

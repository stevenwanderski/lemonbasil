class PagesController < ApplicationController
  def home
  end

  def how_it_works
  end

  def about
  end

  def menus
    @menus = Menu.order(:category)
  end
end

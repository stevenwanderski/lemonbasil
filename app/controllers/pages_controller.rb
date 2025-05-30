class PagesController < ApplicationController
  def about
    @page = Page.find_by(slug: 'about')
    @content = Kramdown::Document.new(@page.body).to_html
    @page_title = 'Lemon&Basil | About'
  end

  def calendar
  end

  def home
    @page_title = 'Lemon&Basil | In-home Meal Prep'
  end

  def meal_prep
    @page = Page.find_by(slug: 'meal-prep')
    @content = Kramdown::Document.new(@page.body).to_html
    @page_title = 'Lemon&Basil | Meal Prep'
  end

  def menus
    @categories = Category.all.order(weight: :asc, created_at: :desc)
    @menus = Menu.order(category_id: :asc, weight: :asc, created_at: :desc)
  end

  def parties
    @page = Page.find_by(slug: 'parties')
    @content = Kramdown::Document.new(@page.body).to_html
    @page_title = 'Lemon&Basil | Parties'
  end
end

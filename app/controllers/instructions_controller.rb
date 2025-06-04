class InstructionsController < ApplicationController
  def index
    user = User.find_by!(slug: params[:slug])

    @meals = user.meals.order(name: :asc).map do |meal|
      { value: meal.name, data: meal.id }
    end
  end

  def show
    user = User.find_by!(slug: params[:slug])
    @meal = user.meals.find(params[:id])
    @instructions = Kramdown::Document.new(@meal.instructions).to_html
  end
end

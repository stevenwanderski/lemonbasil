class InstructionsController < ApplicationController
  def index
    @meals = Meal.order(name: :asc).map do |meal|
      { value: meal.name, data: meal.id }
    end
  end

  def show
    @meal = Meal.find(params[:id])
    @instructions = Kramdown::Document.new(@meal.instructions).to_html
  end
end

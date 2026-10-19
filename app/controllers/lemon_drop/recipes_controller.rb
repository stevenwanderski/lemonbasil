class LemonDrop::RecipesController < ApplicationController
  layout 'lemon_drop'

  def show
    @issue = LemonDrop::Issue.published.find_by!(slug: params[:slug])
    @recipe = @issue.recipes.find_by!(slug: params[:recipe_slug])
  end
end

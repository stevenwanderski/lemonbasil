# Recipes are managed from their Recipes Section's form, and each one is
# edited, hero image included, in a single save.
class Admin::LemonDrop::RecipesController < Admin::LemonDrop::BaseController
  RECIPE_PARAMS = [
    :title, :slug, :kicker, :category, :menu_title, :menu_blurb, :prep_minutes, :cook_minutes, :time_note,
    :total_label, :serves, :tip, :hero_image, :hero_focus, :steps_text,
    { ingredient_groups_attributes: %i[id name ingredients_text position _destroy] }
  ].freeze

  before_action :set_issue_and_section
  before_action :set_recipe, except: [:new, :create, :reorder]

  def new
    @recipe = @recipes_section.build_recipe
  end

  def create
    @recipe = @recipes_section.build_recipe(recipe_params)
    if @recipe.save
      redirect_to edit_admin_lemon_drop_issue_section_path(@issue, @section), notice: 'Recipe added!'
    else
      flash.now[:error] = 'Could not save'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to edit_admin_lemon_drop_issue_section_path(@issue, @section), notice: 'Recipe updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit, status: :unprocessable_entity
    end
  end

  # Moves the Recipe to the end of another Recipes Section in the Issue.
  def move
    target = @issue.sections.lemon_drop_recipes_sections.find(params.require(:to_section_id))
    @recipe.move_to(target.sectionable)
    redirect_to edit_admin_lemon_drop_issue_section_path(@issue, target), notice: 'Recipe moved!'
  end

  # The drag in the Recipe list posts every Recipe id, top first.
  def reorder
    @recipes_section.reorder_recipes(params.require(:recipe_ids))
    head :no_content
  rescue ArgumentError
    head :unprocessable_entity
  end

  def destroy
    @recipe.destroy!
    @recipes_section.renumber_recipes
    redirect_to edit_admin_lemon_drop_issue_section_path(@issue, @section), notice: 'Recipe deleted!'
  end

  private

  def recipe_params
    params.require(:lemon_drop_recipe).permit(*RECIPE_PARAMS)
  end

  def set_issue_and_section
    @issue = ::LemonDrop::Issue.find(params[:issue_id])
    @section = @issue.sections.lemon_drop_recipes_sections.find(params[:section_id])
    @recipes_section = @section.sectionable
  end

  def set_recipe
    @recipe = @recipes_section.recipes.find(params[:id])
  end
end

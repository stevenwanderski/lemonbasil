# Recipes are managed from their Recipes Section's form, and each one is
# edited, hero image included, in a single save. With drawer, the same
# actions serve the live editor's drawer: just the form, and saves answered
# with what to swap into the page.
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
    render :drawer, layout: false if params[:drawer]
  end

  # A new Recipe comes back inside its whole Recipes Section, where it lands.
  def create
    @recipe = @recipes_section.build_recipe(recipe_params)
    if @recipe.save
      return render html: live_page_html(sections: [@section, *menu_overviews]) if params[:drawer]

      redirect_to edit_admin_lemon_drop_issue_section_path(@issue, @section), notice: 'Recipe added!'
    else
      return render :drawer, layout: false, status: :unprocessable_entity if params[:drawer]

      flash.now[:error] = 'Could not save'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render :drawer, layout: false if params[:drawer]
  end

  def update
    if @recipe.update(recipe_params)
      return render html: live_page_html(sections: menu_overviews, recipes: [@recipe.reload]) if params[:drawer]

      redirect_to edit_admin_lemon_drop_issue_section_path(@issue, @section), notice: 'Recipe updated!'
    else
      return render :drawer, layout: false, status: :unprocessable_entity if params[:drawer]

      flash.now[:error] = 'Could not save'
      render :edit, status: :unprocessable_entity
    end
  end

  # The drawer's unsaved changes, as the page would show them; nothing is
  # kept. Images show once uploaded (see previewable_attachments).
  # shortcut: the Menu Overview catches up on Save, not while typing.
  def preview
    attributes = recipe_params
    previewable_attachments(attributes, ::LemonDrop::Recipe)
    render_preview do
      @recipe.assign_attributes(attributes)
      live_page_html(recipes: [@recipe])
    end
  end

  # Moves the Recipe to the end of another Recipes Section in the Issue.
  def move
    target = @issue.sections.lemon_drop_recipes_sections.find(params.require(:to_section_id))
    @recipe.move_to(target.sectionable)
    redirect_to edit_admin_lemon_drop_issue_section_path(@issue, target), notice: 'Recipe moved!'
  end

  # The drag in the Recipe list posts every Recipe id, top first. From the
  # live editor, it answers with the Recipes Section and the Menu Overview.
  def reorder
    @recipes_section.reorder_recipes(params.require(:recipe_ids))
    return render html: live_page_html(sections: [@section, *menu_overviews]) if params[:drawer]

    head :no_content
  rescue ArgumentError
    head :unprocessable_entity
  end

  # From the live editor, answers with its Recipes Section and the Menu Overview.
  def destroy
    @recipe.destroy!
    @recipes_section.renumber_recipes
    return render html: live_page_html(sections: [@section, *menu_overviews]) if params[:drawer]

    redirect_to edit_admin_lemon_drop_issue_section_path(@issue, @section), notice: 'Recipe deleted!'
  end

  private

  # Built from every Recipe's title, blurb and category, so a Recipe save
  # changes them too.
  def menu_overviews
    @issue.sections.lemon_drop_menu_overview_sections
  end

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

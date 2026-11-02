class Admin::LemonDrop::SectionsController < Admin::LemonDrop::BaseController
  # Each Section type's own fields on its form. Types missing here get their
  # forms in later Lemon Drop tickets.
  SECTIONABLE_PARAMS = {
    'LemonDrop::TitlePageSection' => %i[heading tagline date_label cover_image],
    'LemonDrop::IntroSection' => %i[heading body_html signoff icon],
    'LemonDrop::HeroSection' => %i[heading background_image overlay_image background_focus text_color min_height],
    'LemonDrop::TableOfContentsSection' => %i[heading],
    'LemonDrop::RecipesSection' => %i[heading],
    'LemonDrop::MenuOverviewSection' => [:heading, :icon, { category_order: [] }],
    'LemonDrop::GroceryListSection' => [:heading, :icon, { grocery_groups_attributes: %i[id name items_text position _destroy] }],
    'LemonDrop::AllergenSwapSection' => [:heading, :icon, :disclaimer, {
      swap_groups_attributes: %i[id name swaps_text position _destroy],
      swap_recipes_attributes: %i[id title yield_label ingredients steps use_for position _destroy]
    }],
    # images lists the signed ids of the saved images to keep, then any new
    # files: the set as a whole replaces the old one.
    'LemonDrop::OutroSection' => [:heading, :body_html, :cta_label, :cta_url, { images: [] }]
  }.freeze

  before_action :set_issue
  before_action :set_section, except: [:create, :reorder]

  def create
    type = ::LemonDrop::Section::TYPES.find { |name| name.demodulize == params[:section_type] }
    return head :unprocessable_entity if type.nil?

    section = @issue.insert_section(type.constantize.new, position: params[:position])
    redirect_to edit_admin_lemon_drop_issue_section_path(@issue, section), notice: "#{section.sectionable.model_name.human} added!"
  end

  # With drawer, just the form, for the live editor's drawer.
  def edit
    render :drawer, layout: false if params[:drawer]
  end

  # From the live editor's drawer, a save answers with the Section as the
  # page renders it, plus every Table of Contents (its entries come from the
  # other Sections' headings and labels); a refused save, with the form.
  def update
    if @section.update(section_params)
      return render html: live_page_html(sections: [@section, *@issue.sections.lemon_drop_table_of_contents_sections.excluding(@section)]) if params[:drawer]

      redirect_back fallback_location: edit_admin_lemon_drop_issue_section_path(@issue, @section), notice: 'Section updated!'
    elsif params[:drawer]
      render :drawer, layout: false, status: :unprocessable_entity
    else
      flash.now[:error] = 'Could not save'
      render :edit, status: :unprocessable_entity
    end
  end

  # The drawer's unsaved changes, as the page would show them; nothing is
  # kept. Images show once uploaded (see previewable_attachments).
  # shortcut: only the Section itself is previewed, so a Table of Contents
  # catches up on Save; render it from these in-memory changes if that matters.
  def preview
    attributes = section_params
    previewable_attachments(attributes[:sectionable_attributes], @section.sectionable.class)
    render_preview do
      @section.assign_attributes(attributes)
      live_page_html(sections: [@section])
    end
  end

  # The drag in the Section list posts every Section id, top first.
  def reorder
    @issue.reorder_sections(params.require(:section_ids))
    head :no_content
  rescue ArgumentError
    head :unprocessable_entity
  end

  def duplicate
    copy = @section.duplicate
    redirect_to edit_admin_lemon_drop_issue_section_path(@issue, copy), notice: 'Section duplicated!'
  end

  # A Recipes Section's Recipes are deleted with it, or moved to the Recipes
  # Section named by move_recipes_to. From the live editor's drawer, it
  # answers with the Sections that change: any Table of Contents and Menu
  # Overview, and the Recipes Section the Recipes moved to.
  def destroy
    target = @issue.sections.lemon_drop_recipes_sections.excluding(@section).find(params[:move_recipes_to]) if params[:move_recipes_to].present?
    @issue.remove_section(@section, move_recipes_to: target&.sectionable)
    if params[:drawer]
      return render html: live_page_html(sections: [*target, *@issue.sections.lemon_drop_table_of_contents_sections,
        *@issue.sections.lemon_drop_menu_overview_sections])
    end

    redirect_to edit_admin_lemon_drop_issue_path(@issue), notice: 'Section deleted!'
  end

  private

  def section_params
    params.require(:lemon_drop_section).permit(:theme, :anchor, :show_in_toc, :toc_label,
      sectionable_attributes: SECTIONABLE_PARAMS.fetch(@section.sectionable_type, []))
  end

  def set_issue
    @issue = ::LemonDrop::Issue.find(params[:issue_id])
  end

  def set_section
    @section = @issue.sections.find(params[:id])
  end
end

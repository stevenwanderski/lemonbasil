# Every lemon drop admin controller inherits from this: only Admins get in.
class Admin::LemonDrop::BaseController < AdminController
  before_action :authorize_admin_role!

  private

  # For the live editor: Sections and Recipes as the page renders them,
  # marked with their ids, so they can be swapped into the page.
  def live_page_html(sections: [], recipes: [])
    helpers.safe_join(
      sections.map { |section| render_to_string(partial: 'lemon_drop/issues/page_section', locals: { section: section, editable: true }) } +
        recipes.map { |recipe| render_to_string(partial: 'lemon_drop/recipes/recipe', locals: { recipe: recipe, editable: true }) }
    )
  end

  # A drawer form's image fields hold a signed id once the picked file is
  # uploaded; a preview shows those, but never stores a file sent with it.
  def previewable_attachments(attributes, model)
    model.attachment_reflections.each_key do |name|
      value = attributes&.dig(name)
      next if value.nil?

      if value.is_a?(Array)
        attributes[name] = value.grep(String)
      elsif !value.is_a?(String) || value.blank?
        attributes.delete(name)
      end
    end
  end

  # Renders the record with unsaved changes, then undoes everything: replacing
  # an attachment in memory can touch the database.
  def render_preview
    html = nil
    ActiveRecord::Base.transaction do
      html = yield
      raise ActiveRecord::Rollback
    end
    render html: html
  end

  def authorize_admin_role!
    redirect_to admin_clients_path if !current_user.admin?
  end
end

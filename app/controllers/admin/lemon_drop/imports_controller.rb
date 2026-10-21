# Paste (or upload) a week's JSON from a Claude chat, check the preview, then
# confirm to create a new Draft Issue from it.
class Admin::LemonDrop::ImportsController < Admin::LemonDrop::BaseController
  def new; end

  def preview
    @importer = ::LemonDrop::Importer.new(raw_json, admin: current_user)

    if @importer.valid?
      render :preview
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @importer = ::LemonDrop::Importer.new(raw_json, admin: current_user)
    issue = @importer.commit!
    redirect_to edit_admin_lemon_drop_issue_path(issue), notice: 'Draft Issue imported!'
  rescue ::LemonDrop::Importer::Invalid
    flash.now[:error] = 'Could not import'
    render :new, status: :unprocessable_entity
  end

  private

  # An uploaded .json file wins over pasted text.
  def raw_json
    params[:file].present? ? params[:file].read.force_encoding(Encoding::UTF_8) : params[:raw_json]
  end
end

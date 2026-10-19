# Shows an Issue of any status exactly as the public page renders it, for
# Admins only. It sits beside the public controllers, not under Admin::, so
# the public partials resolve to the same paths (Rails prefixes object
# partial paths with the controller's namespace).
class LemonDrop::PreviewsController < Admin::LemonDrop::BaseController
  layout 'lemon_drop'

  def show
    @issue = LemonDrop::Issue.find(params[:issue_id])
    @sections = @issue.page_sections
    render 'lemon_drop/issues/show'
  end
end

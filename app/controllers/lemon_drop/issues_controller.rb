class LemonDrop::IssuesController < ApplicationController
  layout 'lemon_drop'

  def show
    @issue = LemonDrop::Issue.published.find_by!(slug: params[:slug])
    @sections = @issue.sections.visible.includes(:sectionable)
  end
end

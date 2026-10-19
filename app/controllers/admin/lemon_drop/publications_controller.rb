class Admin::LemonDrop::PublicationsController < Admin::LemonDrop::BaseController
  before_action :set_issue

  def create
    @issue.publish!
    redirect_to edit_admin_lemon_drop_issue_path(@issue), notice: 'Issue published!'
  end

  def destroy
    @issue.unpublish!
    redirect_to edit_admin_lemon_drop_issue_path(@issue), notice: 'Issue unpublished.'
  end

  private

  def set_issue
    @issue = ::LemonDrop::Issue.find(params[:issue_id])
  end
end

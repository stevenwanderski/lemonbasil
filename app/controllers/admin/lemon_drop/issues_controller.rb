class Admin::LemonDrop::IssuesController < Admin::LemonDrop::BaseController
  def index
    @issues = ::LemonDrop::Issue.order(starts_on: :desc)
    @issues = @issues.where(status: params[:status]) if ::LemonDrop::Issue.statuses.key?(params[:status])
  end

  def new
    @issue = ::LemonDrop::Issue.new
  end

  def create
    @issue = ::LemonDrop::Issue.new(issue_params)
    @issue.build_default_sections

    if @issue.save
      redirect_to edit_admin_lemon_drop_issue_path(@issue), notice: 'Issue created!'
    else
      flash.now[:error] = 'Could not save'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @issue = ::LemonDrop::Issue.find(params[:id])
  end

  def update
    @issue = ::LemonDrop::Issue.find(params[:id])

    if @issue.update(issue_params)
      redirect_to edit_admin_lemon_drop_issue_path(@issue), notice: 'Issue updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @issue = ::LemonDrop::Issue.find(params[:id])

    if @issue.destroy
      redirect_to admin_lemon_drop_issues_path, notice: 'Issue deleted!'
    else
      redirect_to edit_admin_lemon_drop_issue_path(@issue), alert: @issue.errors.full_messages.to_sentence
    end
  end

  private

  def issue_params
    params.require(:lemon_drop_issue).permit(:title, :slug, :starts_on, :ends_on)
  end
end

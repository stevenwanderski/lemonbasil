# The Issue on its real page design, in an iframe so the page's styles and
# the admin's never mix, with a drawer for the clicked Section's form.
class Admin::LemonDrop::LiveEditorsController < Admin::LemonDrop::BaseController
  def show
    @issue = ::LemonDrop::Issue.find(params[:issue_id])
  end
end

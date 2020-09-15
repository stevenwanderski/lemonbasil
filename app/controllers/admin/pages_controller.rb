class Admin::PagesController < AdminController
  def index
  end

  def edit
    @page = Page.find_by(slug: params[:slug])
  end
end

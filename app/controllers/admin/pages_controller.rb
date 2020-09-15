class Admin::PagesController < AdminController
  def index
  end

  def edit
    @page = Page.find_by(slug: params[:slug])
  end

  def update
    @page = Page.find_by(slug: params[:slug])

    if @page.update(page_params)
      redirect_to admin_page_path(slug: @page.slug), notice: "Saved!"
    else
      redirect_to admin_page_path(slug: @page.slug), alert: "No good. Tell someone."
    end
  end

  private

  def page_params
    params.require(:page).permit(:body)
  end
end

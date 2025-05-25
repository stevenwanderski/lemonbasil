class Admin::ClientMenus::StaplesController < AdminController
  def new
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @staple = Staple.new(staple_category_id: params[:staple_category_id])
  end

  def create
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @staple = Staple.new(staple_params)
    @staple_category = @staple.staple_category

    if @staple.save
      render 'create'
    else
      render 'new', status: 422
    end
  end

  def edit
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @staple = @client_menu.staples.find(params[:id])
  end

  def update
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @staple = @client_menu.staples.find(params[:id])
    @staple_category = @staple.staple_category

    if @staple.update(staple_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def destroy
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @staple = @client_menu.staples.find(params[:id])
    @staple_category = @staple.staple_category
    @staple.destroy!
    @staples = @staple_category.staples.order(:weight)
  end

  private

  def staple_params
    params.require(:staple).permit!
  end
end

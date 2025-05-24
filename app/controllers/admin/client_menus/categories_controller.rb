class Admin::ClientMenus::CategoriesController < AdminController
  def new
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @category = ClientMenuCategory.new
  end

  def create
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @category = ClientMenuCategory.new(category_params)
    @category.client_menu = @client_menu
    @category.weight = @client_menu.client_menu_categories.count

    if @category.save
      @categories = @client_menu.client_menu_categories.order(:weight)
      render 'create'
    else
      render 'new', status: 422
    end
  end

  def edit
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @category = @client_menu.client_menu_categories.find(params[:id])
  end

  def update
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @category = @client_menu.client_menu_categories.find(params[:id])

    if @category.update(category_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def destroy
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @category = @client_menu.client_menu_categories.find(params[:id])
    @category.destroy!
    @categories = @client_menu.client_menu_categories.order(:weight)
  end

  private

  def category_params
    params.require(:client_menu_category).permit!
  end
end

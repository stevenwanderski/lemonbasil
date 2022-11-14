class Admin::ClientMenus::CategoriesController < AdminController
  def edit
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @category = ClientMenuCategory.find(params[:id])
  end

  def update
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @category = ClientMenuCategory.find(params[:id])
    @category.update!(name: 'Howdy!')
  end

  private

  def category_params
    params.require(:client_menu_category).permit!
  end
end

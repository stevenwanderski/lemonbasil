class Admin::ClientMenus::StapleCategoriesController < AdminController
  def new
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple_category = StapleCategory.new(client_menu_id: params[:client_menu_id])
  end

  def create
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple_category = StapleCategory.new(staple_category_params)

    if @staple_category.save
      @staple_categories = @client_menu.staple_categories.order(:weight)

      render 'create'
    else
      render 'new', status: 422
    end
  end

  def edit
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple_category = StapleCategory.find(params[:id])
  end

  def update
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple_category = StapleCategory.find(params[:id])

    if @staple_category.update(staple_category_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def destroy
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple_category = StapleCategory.find(params[:id])
    @staple_category.destroy!
    @staple_categories = @client_menu.staple_categories.order(:weight)
  end

  private

  def staple_category_params
    params.require(:staple_category).permit!
  end
end

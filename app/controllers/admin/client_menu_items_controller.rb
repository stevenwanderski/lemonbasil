class Admin::ClientMenuItemsController < AdminController
  def new
    @client_menu_item = ClientMenuItem.new(
      client_menu_category_id: params[:client_menu_category_id]
    )
  end

  def create
    @client_menu = ClientMenu.new(client_menu_params)

    if @client_menu.save
      redirect_to admin_client_menus_path, notice: 'Client Menu created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    @client_menu_item = ClientMenuItem.find(params[:id])
  end

  def update
    @client_menu_item = ClientMenuItem.find(params[:id])

    if @client_menu.update(client_menu_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def destroy
    @client_menu = ClientMenu.find(params[:id])
    @client_menu.destroy
    redirect_to admin_client_menus_path, notice: 'Client Menu deleted!'
  end

  private

  def client_menu_item_params
    params.require(:client_menu_item).permit!
  end
end

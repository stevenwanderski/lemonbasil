class Admin::ClientMenus::ItemsController < AdminController
  def new
    @client_menu_item = ClientMenuItem.new(
      client_menu_category_id: params[:client_menu_category_id]
    )
  end

  def create
    @client_menu_item = ClientMenuItem.new(client_menu_item_params)
    @category = @client_menu_item.client_menu_category
    @client_menu = ClientMenu.find(params[:client_menu_id])

    if @client_menu_item.save
      render 'create'
    else
      render 'new', status: 422
    end
  end

  def edit
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @client_menu_item = ClientMenuItem.find(params[:id])
  end

  def update
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @client_menu_item = ClientMenuItem.find(params[:id])

    if @client_menu_item.update(client_menu_item_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def destroy
    @client_menu_item = ClientMenuItem.find(params[:id])
    @category = @client_menu_item.client_menu_category
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @client_menu_item.destroy
  end

  private

  def client_menu_item_params
    params.require(:client_menu_item).permit!
  end
end

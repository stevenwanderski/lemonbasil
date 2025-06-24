class Admin::ClientMenus::SharesController < AdminController
  def new
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
    @users = User.all.order(email: :asc)
  end

  def update
    client_menu = current_user.client_menus.find(params[:client_menu_id])
    user = User.find(client_menu_params[:user_id])

    values = {
      user_id: user.id
    }

    client_menu.duplicate!(values)

    redirect_to admin_client_menu_menu_items_path(client_menu), status: :see_other, notice: "Menu was successfully shared with #{user.email}"
  end

  private

  def client_menu_params
    params.require(:client_menu).permit!
  end
end

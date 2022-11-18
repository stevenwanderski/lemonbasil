class Admin::ClientMenus::DuplicatesController < AdminController
  def new
    @client_menu_to_copy = ClientMenu.find(params[:client_menu_id])
    @client_menu = ClientMenu.new
    @clients = Client.all.order(:last_name)
  end

  def create
    client_menu = ClientMenu.find(params[:client_menu_id])

    values = {
      client_id: client_menu_params[:client_id],
      due_at: client_menu_params[:due_at],
      job_date: client_menu_params[:job_date],
      show_pricing: client_menu_params[:show_pricing]
    }

    menu = client_menu.duplicate!(values)

    redirect_to admin_client_menu_menu_items_path(menu), status: :see_other
  end

  private

  def client_menu_params
    params.require(:client_menu).permit!
  end
end

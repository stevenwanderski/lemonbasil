class Api::ClientMenusController < ApiController
  def index
    client_menus = ClientMenu.all.order(created_at: :desc)

    render json: client_menus
  end

  def create
    client_menu = ClientMenu.create!(client_menu_params)

    render json: client_menu
  end

  private

  def client_menu_params
    params.permit(:client_id, :due_at)
  end
end

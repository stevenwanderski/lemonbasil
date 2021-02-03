class Api::ClientMenusController < ApiController
  def index
    client_menus = ClientMenu.all.order(created_at: :desc)

    render json: client_menus
  end

  def create
    client_menu = ClientMenu.create!(
      client_id: params[:client_id]
    )

    render json: client_menu
  end
end

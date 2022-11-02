class Api::ClientMenusController < ApiController
  def index
    client_menus = ClientMenu.all.order(created_at: :desc)

    render json: client_menus
  end

  def create
    client_menu = ClientMenu.create!(client_menu_params)

    render json: client_menu
  end

  def show
    client_menu = ClientMenu.find(params[:id])

    render json: client_menu
  end

  def update
    client_menu = ClientMenu.find(params[:id])
    client_menu.update!(client_menu_params)
    render json: client_menu
  end

  def submission
    client_menu = ClientMenu.find(params[:client_menu_id])
    client_menu_submission = client_menu.newest_submission

    render json: client_menu_submission
  end

  def duplicate
    client_menu = ClientMenu.find(params[:client_menu_id])

    values = {
      client_id: params[:client_id],
      due_at: params[:due_at],
      job_date: params[:job_date]
    }

    menu = client_menu.duplicate!(values)

    render json: menu
  end

  private

  def client_menu_params
    params.permit(:client_id, :due_at, :message, :job_date, :show_pricing)
  end
end

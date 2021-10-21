class Api::ClientMenuSubmissionsController < ApiController
  def show
    client_menu = ClientMenu.find(params[:client_menu_id])
    client_menu_submission = client_menu.newest_submission

    render json: client_menu_submission
  end
end

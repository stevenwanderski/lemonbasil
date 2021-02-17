class Api::ClientMenuSubmissionsController < ApiController
  def create
    client_menu_submission = ClientMenuSubmission.create!(client_menu_submission_params)

    params[:client_menu_item_ids].each do |id|
      client_menu_submission.client_menu_selections.create!(
        client_menu_item_id: id
      )
    end

    render json: client_menu_submission
  end

  def show
    client_menu = ClientMenu.find(params[:client_menu_id])
    client_menu_submission = client_menu.client_menu_submission

    render json: client_menu_submission
  end

  private

  def client_menu_submission_params
    params.permit(:client_menu_id, :message)
  end
end

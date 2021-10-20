class ClientMenuSubmissionsController < ApplicationController
  layout 'minimal'

  def new
    @menu = ClientMenu.find_by(slug: params[:slug])
    @client = @menu.client
    @categories = @menu.client_menu_categories.order(weight: :asc)
    @client_menu_submission = @menu.newest_submission || ClientMenuSubmission.new
  end

  def create
    @client_menu_submission = ClientMenuSubmission.new(client_menu_submission_params)

    @menu = ClientMenu.find(params[:client_menu_id])
    @client = @menu.client
    @categories = @menu.client_menu_categories.order(weight: :asc)

    if !request.headers['X-Up-Validate']
      @client_menu_submission.client_menu = @menu
      @client_menu_submission.save!
      redirect_to menu_slug_success_path(slug: @menu.slug)
    end
  end

  def show
    client_menu = ClientMenu.find(params[:client_menu_id])
    client_menu_submission = client_menu.newest_submission

    render json: client_menu_submission
  end

  private

  def client_menu_submission_params
    params.require(:client_menu_submission).permit! if !params[:client_menu_submission].blank?
  end
end

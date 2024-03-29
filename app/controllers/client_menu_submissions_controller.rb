class ClientMenuSubmissionsController < ApplicationController
  layout 'minimal'

  def new
    @menu = ClientMenu.find_by(slug: params[:slug])
    @client = @menu.client
    @categories = @menu.client_menu_categories.order(weight: :asc)
    @client_menu_submission = @menu.newest_submission || ClientMenuSubmission.new
  end

  def create
    client_menu_submission = ClientMenuSubmission.new(client_menu_submission_params)
    client_menu = ClientMenu.find(params[:client_menu_id])

    client_menu_submission.client_menu = client_menu
    client_menu_submission.save!

    ClientMenuMailer
      .with(client_menu: client_menu)
      .client_submission
      .deliver

    redirect_to menu_slug_success_path(slug: client_menu.slug)
  end

  def success
    @client_menu = ClientMenu.find_by(slug: params[:slug])
    @staples = @client_menu.staples
  end

  def update_totals
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @client_menu_submission = ClientMenuSubmission.new(client_menu_submission_params)
  end

  def save_staples
    @client_menu = ClientMenu.find_by(slug: params[:slug])
    @client_menu.update!(client_menu_params)

    redirect_to staples_success_path(slug: @client_menu.slug)
  end

  def staple_success
  end

  private

  def client_menu_submission_params
    params.require(:client_menu_submission).permit! if !params[:client_menu_submission].blank?
  end

  def client_menu_params
    params.require(:client_menu).permit!
  end
end

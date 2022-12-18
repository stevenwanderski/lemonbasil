class Staples::ClientMenusController < ApplicationController
  before_action :assign_client_menu

  def edit
    @staples = @client_menu.staples
  end

  def update
    @client_menu.update!(client_menu_params)

    redirect_to staples_client_menu_path(@client_menu)
  end

  def show
  end

  private

  def assign_client_menu
    @client_menu = ClientMenu.find(params[:id])
  end

  def client_menu_params
    params.require(:client_menu).permit!
  end
end
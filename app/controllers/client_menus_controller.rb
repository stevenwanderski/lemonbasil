class ClientMenusController < ApplicationController
  def show
    @menu = ClientMenu.find_by(slug: params[:slug])
  end
end

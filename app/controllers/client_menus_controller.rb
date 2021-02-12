class ClientMenusController < ApplicationController
  layout 'minimal'

  def show
    menu = ClientMenu.find_by(slug: params[:slug])
    @menu_id = menu.id
    @token = ENV['API_TOKEN']
  end
end

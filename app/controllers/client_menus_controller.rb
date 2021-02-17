class ClientMenusController < ApplicationController
  layout :get_layout

  def show
    menu = ClientMenu.find_by(slug: params[:slug])
    @menu_id = menu.id
    @token = ENV['API_TOKEN']
  end

  def success
  end

  private

  def get_layout
    if action_name == 'show'
      return 'minimal'
    end

    'application'
  end
end

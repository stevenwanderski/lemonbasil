class ClientMenusController < ApplicationController
  layout :get_layout

  def show
    @menu = ClientMenu.find_by(slug: params[:slug])
    @client = @menu.client
    @categories = @menu.client_menu_categories.order(weight: :asc)
    @client_menu_submission = ClientMenuSubmission.new
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

class ClientMenusController < ApplicationController
  layout :get_layout

  def show
    menu = ClientMenu.find_by(slug: params[:slug])
    @menu_id = menu.id
    @token = ENV['API_TOKEN']

    if menu.newest_submission.present?
      selection_ids = menu
        .newest_submission
        .client_menu_selections
        .map(&:client_menu_item_id)
    else
      selection_ids = []      
    end

    @sections = menu.client_menu_categories.order(weight: :asc).map do |category|
      {
        category: {
          id: category.id,
          name: category.name,
          description: category.description
        },
        items: category.client_menu_items.order(weight: :asc).map do |item|
          {
            id: item.id,
            name: item.name,
            cost: item.cost,
            selected: selection_ids.include?(item.id)
          }
        end
      }
    end
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

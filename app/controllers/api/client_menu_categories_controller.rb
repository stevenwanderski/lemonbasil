class Api::ClientMenuCategoriesController < ApiController
  def index
    client_menu = ClientMenu.find(params[:client_menu_id])

    render json: client_menu.client_menu_categories.order(weight: :asc)
  end

  def create
    client_menu = ClientMenu.find(params[:client_menu_id])
    category = client_menu
      .client_menu_categories
      .create!(client_menu_category_params)

    render json: category
  end

  def update_weights
    weights = params[:weights]

    weights.each do |id, weight|
      category = ClientMenuCategory.find(id)
      category.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end

  private

  def client_menu_category_params
    params.permit(:name)
  end
end

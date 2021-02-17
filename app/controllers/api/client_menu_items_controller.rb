class Api::ClientMenuItemsController < ApiController
  def index
    client_menu_category = ClientMenuCategory.find(params[:client_menu_category_id])

    items = client_menu_category
      .client_menu_items
      .order(weight: :asc, created_at: :asc)

    render json: items
  end

  def create
    client_menu_category = ClientMenuCategory.find(params[:client_menu_category_id])
    item = client_menu_category
      .client_menu_items
      .create!(client_menu_item_params)

    render json: item
  end

  def update
    item = ClientMenuItem.find(params[:id])
    item.update!(client_menu_item_params)
    render json: item
  end

  def destroy
    item = ClientMenuItem.find(params[:id])
    item.destroy!
    render json: item
  end

  def update_weights
    weights = params[:weights]

    weights.each do |id, weight|
      item = ClientMenuItem.find(id)
      item.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end

  private

  def client_menu_item_params
    params.permit(:name, :cost, :quantity, :weight, :description)
  end
end

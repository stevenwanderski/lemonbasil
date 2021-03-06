class Api::MenusController < ApiController
  def update_weights
    weights = params[:weights]

    weights.each do |id, weight|
      menu = Menu.find(id)
      menu.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end
end

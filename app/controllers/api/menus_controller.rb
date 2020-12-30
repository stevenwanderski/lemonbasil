class Api::MenusController < ApiController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_token!, only: [:index]

  def update_weights
    weights = params[:weights]

    weights.each do |id, weight|
      menu = Menu.find(id)
      menu.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end
end

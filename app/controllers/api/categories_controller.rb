class Api::CategoriesController < ApiController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_token!, only: [:index]

  def update_weights
    weights = params[:weights]

    weights.each do |id, weight|
      category = Category.find(id)
      category.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end
end

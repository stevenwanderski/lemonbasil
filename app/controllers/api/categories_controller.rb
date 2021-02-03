class Api::CategoriesController < ApiController
  def update_weights
    weights = params[:weights]

    weights.each do |id, weight|
      category = Category.find(id)
      category.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end
end

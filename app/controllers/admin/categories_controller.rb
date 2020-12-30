class Admin::CategoriesController < AdminController
  def index
    @categories = Category.all.order(weight: :asc, created_at: :desc)
    @token = ENV['API_TOKEN']
  end

  def new
    @category = Category.new(weight: 0)
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_path, notice: 'Section created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])

    if @category.update!(category_params)
      redirect_to admin_categories_path, notice: 'Section updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit
    end
  end

  def show
    @category = Category.find(params[:id])
    @menus = @category.menus.order(weight: :asc, created_at: :desc)
    @token = ENV['API_TOKEN']
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to admin_categories_path, notice: 'Section deleted!'
  end

  private

  def category_params
    params.require(:category).permit(:name, :weight)
  end
end

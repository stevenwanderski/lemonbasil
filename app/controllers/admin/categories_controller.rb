class Admin::CategoriesController < AdminController
  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_path, success: 'Section created!'
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
      redirect_to admin_categories_path, success: 'Section updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit
    end
  end

  def show
    @category = Category.find(params[:id])
    @menus = @category.menus
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end

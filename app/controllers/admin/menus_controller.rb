class Admin::MenusController < AdminController
  def index
  end

  def new
    category = Category.find(params[:category_id])
    @menu = Menu.new(category_id: category.id, weight: 0)
  end

  def create
    @menu = Menu.new(menu_params)

    if @menu.save
      redirect_to admin_category_path(@menu.category), notice: 'Menu Item created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    category = Category.find(params[:category_id])
    @menu = Menu.find(params[:id])
  end

  def update
    @menu = Menu.find(params[:id])

    if @menu.update(menu_params)
      redirect_to admin_category_path(@menu.category), notice: 'Menu Item updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit
    end
  end

  private

  def menu_params
    params.require(:menu).permit(:name, :description, :category_id, :weight)
  end
end

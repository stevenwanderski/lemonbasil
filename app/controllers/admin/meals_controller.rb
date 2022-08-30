class Admin::MealsController < AdminController
  def index
    @meals = Meal.order(name: :asc).page(params[:page])
  end

  def new
    @meal = Meal.new
  end

  def edit
    @meal = Meal.find(params[:id])
  end

  def create
    @meal = Meal.new(meal_params)

    if @meal.save
      redirect_to edit_admin_meal_path(@meal), notice: "Successfully created #{@meal.name}"
    else
      render 'new'
    end
  end

  def update
    @meal = Meal.find(params[:id])

    if @meal.update(meal_params)
      redirect_to admin_meal_path(@meal), notice: 'Successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @meal = Meal.find(params[:id])
    @meal.destroy
    redirect_to admin_meals_path, notice: "Successfully deleted #{@meal.name}"
  end

  private

  def meal_params
    params.require(:meal).permit(:name, :instructions)
  end
end

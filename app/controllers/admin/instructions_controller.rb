class Admin::InstructionsController < AdminController
  def index
    @meals = current_user.meals.order(name: :asc).page(params[:page])

    @meals_lookup = current_user.meals.order(name: :asc).map do |meal|
      { value: meal.name, data: meal.id }
    end
  end

  def new
    @meal = Meal.new
  end

  def edit
    @meal = current_user.meals.find(params[:id])
  end

  def create
    @meal = current_user.meals.build(meal_params)

    if @meal.save
      redirect_to admin_instructions_path, notice: "Successfully created #{@meal.name}"
    else
      render 'new'
    end
  end

  def update
    @meal = current_user.meals.find(params[:id])

    if @meal.update(meal_params)
      redirect_to admin_instructions_path, notice: 'Successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @meal = current_user.meals.find(params[:id])
    @meal.destroy
    redirect_to admin_instructions_path, notice: "Successfully deleted #{@meal.name}"
  end

  private

  def meal_params
    params.require(:meal).permit(:name, :instructions)
  end
end

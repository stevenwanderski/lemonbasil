class Admin::UsersController < AdminController
  before_action :authorize_admin_role!

  def index
    @users = User.all.order(email: :asc).page(params[:page]).per(30)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: 'User created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update!(user_params)
      redirect_to admin_users_path, notice: 'User updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: 'User deleted!'
  end

  def switch_user
    @user = User.find(params[:id])
    sign_in(:user, @user)
    redirect_to admin_users_path, notice: "Logged in as #{@user.email}"
  end

  private

  def authorize_admin_role!
    redirect_to admin_clients_path if !current_user.admin?
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end

class Admin::AccountController < AdminController
  def show
  end

  def update
    if current_user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      bypass_sign_in(current_user)
      redirect_to admin_account_path, notice: 'Success!'
    else
      flash[:error] = 'An error ocurred and the password could not be saved.'
      redirect_to admin_account_path
    end
  end
end

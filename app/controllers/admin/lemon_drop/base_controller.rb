# Every lemon drop admin controller inherits from this: only Admins get in.
class Admin::LemonDrop::BaseController < AdminController
  before_action :authorize_admin_role!

  private

  def authorize_admin_role!
    redirect_to admin_clients_path if !current_user.admin?
  end
end

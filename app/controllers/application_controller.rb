class ApplicationController < ActionController::Base
  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    admin_pages_path
  end

  private

  def layout_by_resource
    if devise_controller?
      'admin'
    else
      'application'
    end
  end
end

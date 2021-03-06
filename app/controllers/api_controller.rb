class ApiController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_token!

  private

  def authenticate_token!
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, ENV['API_TOKEN'])
    end
  end
end

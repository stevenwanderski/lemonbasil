RequestTracker.configure do |config|
  config.enabled_environments = ['production']

  config.current_user = ->(request) {
    warden = request.env["warden"]
    warden&.user(:user)&.email
  }
end
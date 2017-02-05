class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # Done by checking session request from the cookie with the secret base key
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

end

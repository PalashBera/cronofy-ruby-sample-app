class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  def login(user)
    session[:user_id] = user.id
  end

  def logout
    session.delete(:user_id)
    @current_user = nil
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def cronofy_client
    @cronofy ||= Cronofy::Client.new(
        client_id: ENV['CRONOFY_CLIENT_ID'],
        client_secret: ENV['CRONOFY_CLIENT_SECRET'],
        access_token: current_user.cronofy_access_token,
        refresh_token: current_user.cronofy_refresh_token
    )
  end
end
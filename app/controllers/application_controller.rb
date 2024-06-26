class ApplicationController < ActionController::Base
  before_action :auth
  before_action :redirect_if_not_authenticated

  def redirect_if_not_authenticated
    redirect_to login_path, flash: { error: "You need to log in to continue." } unless @auth.user?
  end

  def redirect_if_authenticated
    redirect_to root_path, flash: { info: "Already in? Looks like you know your way around." } if @auth.user?
  end

  def auth
    @auth ||= AuthService.new(session, cookies)
  end
end

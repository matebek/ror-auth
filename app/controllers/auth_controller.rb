class AuthController < ApplicationController
  skip_before_action :redirect_if_not_authenticated, only: [:new, :create, :destroy]
  before_action :redirect_if_authenticated, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])

    if @auth.login(@user, user_params[:password], user_params[:remember_me] == "1")
      redirect_to root_path, flash: { success: "Hello, friend. Access granted." }
    else
      flash.now[:error] = "Authentication failed. The provided credentials do not match our records."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @auth.logout
    redirect_to login_path, flash: { success: "Disconnecting. Hope to see you again soon." }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end
end

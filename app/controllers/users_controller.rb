class UsersController < ApplicationController
  skip_before_action :redirect_if_not_authenticated, only: [:new, :create]
  before_action :redirect_if_authenticated, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @auth.force_login(@user)
      redirect_to root_path, flash: { success: "User account created, happy hacking!" }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @auth.user.destroy
    @auth.logout
    redirect_to login_path, flash: { success: "Your account has been deleted. See you on the other side." }
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end

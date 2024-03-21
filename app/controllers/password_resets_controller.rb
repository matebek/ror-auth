class PasswordResetsController < ApplicationController
  skip_before_action :redirect_if_not_authenticated
  before_action :redirect_if_authenticated
  before_action :get_user_by_token, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.find_by(email: user_params[:email])

    if(@user.present?)
      password_reset_token = @user.generate_token_for(:password_reset)
      UserMailer.password_reset_email(@user, password_reset_token).deliver_later
    end

    redirect_to login_path, flash: { success: "If the provided email address exists in our system, password reset instructions have been sent to it." }
  end

  def edit
    # No additional code needed here, @user is already set by get_user_by_token in the before_action filter
  end

  def update
    if @user.update(user_params)
      redirect_to login_path, flash: { success: "Your password has been successfully reset." }
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def get_user_by_token
    @user = User.find_by_token_for(:password_reset, params[:token])

    if @user.nil?
      redirect_to login_path, flash: { error: "The password reset link has expired. Please request a new one." }
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

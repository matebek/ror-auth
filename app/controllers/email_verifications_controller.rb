class EmailVerificationsController < ApplicationController
  def create
    unless @auth.user.verified?
      @auth.user.send_verification_email
      flash[:success] = "Verification email sent. Check your inbox."
    end

    redirect_back fallback_location: root_path
  end

  def update
    user = User.find_by_token_for(:email_verification, params[:token])

    if user == @auth.user && user.update_attribute(:verified_at, Time.now.utc)
      flash[:success] = "Email address verified."
    else
      flash[:error] = "The email verification link has expired or invalid. Please request a new one."
    end

    redirect_to root_path
  end
end

class UserMailer < ApplicationMailer
  def password_reset_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Reset your password")
  end

  def email_verification_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Verify your email address")
  end
end

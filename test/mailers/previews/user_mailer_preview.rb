# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def password_reset_email
    user = User.first
    token = user.generate_token_for(:password_reset)
    UserMailer.password_reset_email(user, token)
  end
end

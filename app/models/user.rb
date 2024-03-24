class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 } # The rest of the validation rules are inherited from has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }

  generates_token_for :password_reset, expires_in: 15.minutes do
    # Last 10 characters of password salt, which changes when password is updated:
    password_salt&.last(10)
  end

  generates_token_for :email_verification, expires_in: 1.week do
    "#{email}_#{verified_at}"
  end

  def verified?
    verified_at.present?
  end

  def send_verification_email
    token = generate_token_for(:email_verification)
    UserMailer.email_verification_email(self, token).deliver_later
  end
end

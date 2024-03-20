class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 } # The rest of the validation rules are inherited from has_secure_password

  normalizes :email, with: -> email { email.strip.downcase }
end

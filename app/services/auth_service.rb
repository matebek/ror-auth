class AuthService
  def initialize(session, cookies)
    @session = session
    @cookies = cookies
  end

  def login(user, password, remember_me: false)
    return false unless user.authenticate(password)

    if remember_me
      create_remembered_session_for_user(user)
    else
      create_session_for_user(user)
    end

    true
  end

  def force_login(user)
    create_session_for_user(user)
    true
  end

  def logout
    @session.destroy
    @cookies.delete(:remember_token)
  end

  def user
    @user ||= user_for_session || user_for_remember_token
  end

  def user?
    user.present?
  end

  private

  def create_session_for_user(user)
    @session[:user_id] = user.id
  end

  def create_remembered_session_for_user(user)
    create_session_for_user(user)

    remember_token = SecureRandom.urlsafe_base64
    @cookies.permanent.signed[:remember_token] = remember_token
    user.update_attribute(:remember_token, remember_token)
  end

  def user_for_session
    User.find_by(id: @session[:user_id]) if @session[:user_id]
  end

  def user_for_remember_token
    # We don't need to perform any further checks if the remember_token does not exist
    return nil if @cookies[:remember_token].blank?

    remember_token = @cookies.signed[:remember_token]

    # If remember_token was tampered, we delete the cookie
    if remember_token.blank?
      @cookies.delete(:remember_token)
      return nil
    end

    user = User.find_by(remember_token:)

    if user
      # In case we were able to find the user, we generate a new token
      create_remembered_session_for_user(user)
    else
      # In case we weren't able to find the user, we delete the cookie
      @cookies.delete(:remember_token)
    end

    user
  end
end

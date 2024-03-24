class AuthService
  def initialize(session, cookies)
    @session = session
    @cookies = cookies
  end

  def login(user, password, remember_me = false)
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
    @user ||= get_user_for_session || get_user_for_remember_token
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
    user.update_attribute(:remember_token , remember_token)
  end

  def get_user_for_session
    User.find_by(id: @session[:user_id]) if @session[:user_id]
  end

  def get_user_for_remember_token
    return unless @cookies[:remember_token].present?

    remember_token = @cookies.signed[:remember_token]

    unless remember_token.present?
      @cookies.delete(:remember_token)
      return nil
    end

    user = User.find_by(remember_token: remember_token)

    if user
      create_remembered_session_for_user(user)
    else
      @cookies.delete(:remember_token)
    end

    user
  end
end

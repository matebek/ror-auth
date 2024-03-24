require "test_helper"

class AuthServiceTest < ActiveSupport::TestCase
  def setup
    @session = ActionController::TestRequest.new({}, {}, nil).session

    # Stubbing session.destroy as ActionController::TestRequest
    # session returns a hash, not an instance of a Session.
    # rubocop:disable Lint/NestedMethodDefinition
    def @session.destroy
      replace({})
    end
    # rubocop:enable Lint/NestedMethodDefinition

    @cookies = ActionDispatch::TestRequest.new(Rails.application.env_config.deep_dup).cookie_jar
    @auth = AuthService.new(@session, @cookies)
  end

  test "login should return false if authentication fails" do
    assert_not @auth.login(@user, "wrong_password")
  end

  test "login should create session for user and return true if authentication succeeds" do
    assert @auth.login(@user, "correct_password")
    assert_equal @user.id, @session[:user_id]
    assert_nil @cookies.signed[:remember_token]
  end

  test "login should create remembered session for user if remember_me is true" do
    assert @auth.login(@user, "correct_password", remember_me: true)
    assert_equal @user.id, @session[:user_id]
    assert_equal @user.remember_token, @cookies.signed[:remember_token]
  end

  test "user lookup using the remember_me cookie should regenerate the remember_token" do
    assert @auth.login(@user, "correct_password", remember_me: true)
    old_remember_token = @cookies.signed[:remember_token]

    # Destroying the session forcing the @auth.user lookup to use the remember_token cookie
    @session.destroy
    assert_nil @session[:user_id]

    # Looking up the user again should create a new session for the user
    @auth.user.reload
    new_remember_token = @cookies.signed[:remember_token]

    assert_equal @user.id, @session[:user_id]
    assert_equal @auth.user.remember_token, new_remember_token
    # Accessing the remember_token should renew the token value in the database
    assert_not_equal old_remember_token, new_remember_token
  end

  test "force_login should create session for user" do
    assert @auth.force_login(@user)
    assert_equal @user.id, @session[:user_id]
  end

  test "logout should destroy session and delete remember_token" do
    @auth.login(@user, "correct_password", remember_me: true)
    @auth.logout
    assert_nil @session[:user_id]
    assert_nil @cookies[:remember_token]
  end

  test "user should return nil if no user is authenticated" do
    assert_nil @auth.user
  end

  test "user should return authenticated user" do
    @auth.force_login(@user)
    assert_equal @user, @auth.user
  end

  test "user? should return false if no user is authenticated" do
    assert_not @auth.user?
  end

  test "user? should return true if user is authenticated" do
    @auth.force_login(@user)
    assert @auth.user?
  end
end

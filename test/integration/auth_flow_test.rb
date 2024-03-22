require "test_helper"

class AuthFlowTest < ActionDispatch::IntegrationTest
  test "user should be able to log in" do
    login

    # Assert that user session is created and remember token is not set
    assert_equal @user.id, session[:user_id]
    assert_nil cookies[:remember_token]

    # Assert that the landing page is displayed after a successful login
    assert_select "h1", "Welcome aboard, Test User"
  end

  test "user redirected to login with invalid session" do
    session = open_session

    session.post login_path, params: { user: { email: @user.email, password: @user.password } }
    session.assert_redirected_to root_path

    # Reset the session and imiatate a new visit to the site
    session.reset!
    session.get root_path

    # Assert that user is redirected to the login page
    session.assert_redirected_to login_path
    session.follow_redirect!
    session.assert_select "h1", "Log in"
  end

  test "user should be able to log in with remember me functionality" do
    login(true)

    # Assert that user session is created and remember token is set
    assert_equal @user.id, session[:user_id]
    assert_not_nil cookies[:remember_token]

    # Assert that the landing page is displated
    assert_select "h1", "Welcome aboard, Test User"
  end

  test "user can be authenticated with remember token even after session reset" do
    session = open_session

    session.post login_path, params: { user: { email: @user.email, password: @user.password, remember_me: "1" } }
    session.assert_redirected_to root_path

    old_remember_token = session.cookies[:remember_token]
    # Resetting the session imitating a new visit to the site
    session.reset!
    # Pass through the old remember token after session reset
    session.cookies[:remember_token] = old_remember_token
    session.get root_path

    # Assert that the user stays on the landing page
    session.assert_response :success
    session.assert_select "h1", "Welcome aboard, Test User"

    # Assert that the user session is recreated
    session.assert_equal @user.id, session.session[:user_id]
    # Assert that the remember_token is refreshed
    session.assert_not_equal old_remember_token, session.cookies[:remember_token]
  end

  test "user should be able to log out and clear all session tokens" do
    login(true)

    # Log the user out
    delete logout_path
    assert_redirected_to login_path
    follow_redirect!

    # Assert that user session tokens are cleared
    assert_nil session[:user_id]
    assert_empty cookies[:remember_token]

    # Assert that user is redirected to the login page
    assert_select "h1", "Log in"
  end
end

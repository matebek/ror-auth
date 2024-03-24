require "test_helper"

class AuthFlowTest < ActionDispatch::IntegrationTest
  EXPECTED_LOGIN_SUCCESS_FLASH = "Hello, friend. Access granted."
  EXPECTED_LOGIN_ERROR_FLASH = "You need to log in to continue."
  EXPECTED_LOGOUT_SUCCESS_FLASH = "Disconnecting. Hope to see you again soon."

  test "should access login form" do
    get login_path

    assert_response :success
    assert_select "h1", "Log in"
    assert_select "form[action=?]", login_path, method: :post do
      assert_select "input[placeholder=?]", "Please enter your email address"
      assert_select "input[placeholder=?]", "Please enter your password"
      assert_select "input[type=?][value=?]", "submit", "Log in"
    end
  end

  test "should log in" do
    login

    # Assert that user session is created and remember token is not set
    assert_equal @user.id, session[:user_id]
    assert_nil cookies[:remember_token]
    # Assert that the landing page is displayed
    assert_select "h1", "Welcome aboard, Bob"
    assert_flash :success, EXPECTED_LOGIN_SUCCESS_FLASH
  end

  test "should redirected to login with invalid session" do
    session = open_session

    session.post login_path, params: { user: @user_params }
    session.assert_redirected_to root_path

    # Reset the session and imiatate a new visit to the site
    session.reset!
    session.get root_path

    # Assert that user is redirected to the login page
    session.assert_redirected_to login_path
    session.follow_redirect!
    session.assert_select "h1", "Log in"
    assert_flash :error, EXPECTED_LOGIN_ERROR_FLASH, session
  end

  test "should log in with remember me functionality" do
    login(remember_me: true)

    # Assert that user session is created and remember token is set
    assert_equal @user.id, session[:user_id]
    assert_not_nil cookies[:remember_token]
    # Assert that the landing page is displated
    assert_select "h1", "Welcome aboard, Bob"
    assert_flash :success, EXPECTED_LOGIN_SUCCESS_FLASH
  end

  test "should authenticate user using remember_token" do
    session = open_session

    session.post login_path, params: { user: { **@user_params, remember_me: "1" } }
    session.assert_redirected_to root_path

    old_remember_token = session.cookies[:remember_token]
    # Resetting the session imitating a new visit to the site
    session.reset!
    # Pass through the old remember token after session reset
    session.cookies[:remember_token] = old_remember_token

    session.get root_path

    # Assert that the user stays on the landing page
    session.assert_response :success
    # Assert that the user session is recreated
    session.assert_equal @user.id, session.session[:user_id]
    # Assert that the remember_token is refreshed
    session.assert_not_equal old_remember_token, session.cookies[:remember_token]
  end

  test "should log out user and clear all session tokens" do
    login(remember_me: true)

    # Log the user out
    delete logout_path

    assert_redirected_to login_path
    follow_redirect!
    # Assert that user session tokens are cleared
    assert_nil session[:user_id]
    assert_empty cookies[:remember_token]
    # Assert that user is redirected to the login page
    assert_select "h1", "Log in"
    assert_flash :success, EXPECTED_LOGOUT_SUCCESS_FLASH
  end
end

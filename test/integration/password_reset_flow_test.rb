require "test_helper"

class PasswordResetFlowTest < ActionDispatch::IntegrationTest
  PASSWORD_RESET_TOKEN_TTL = 15.minutes
  EXPECTED_FORGOT_PASSWORD_SUCCESS_FLASH = "If the provided email address exists in our system, " \
                                           "password reset instructions have been sent to it."
  EXPECTED_PASSWORD_RESET_ERROR_FLASH = "The password reset link has expired or invalid. Please request a new one."
  EXPECTED_PASSWORD_RESET_SUCCESS_FLASH = "Your password has been successfully reset."

  test "should access forgot password form" do
    get new_password_reset_path

    assert_response :success
    assert_select "h1", "Forgot password"
    assert_select "form[action=?]", new_password_reset_path, method: :post do
      assert_select "input[placeholder=?]", "Please enter your email address"
      assert_select "input[type=?][value=?]", "submit", "Request reset link"
    end
  end

  test "should access password reset form with valid token" do
    token = @user.generate_token_for(:password_reset)

    get edit_password_reset_path(token)

    assert_response :success
    assert_select "h1", "Reset password"
    assert_select "form[action=?]", edit_password_reset_path(token), method: :patch do
      assert_select "input[placeholder=?]", "Please enter your password"
      assert_select "input[placeholder=?]", "Please confirm your password"
      assert_select "input[type=?][value=?]", "submit", "Reset password"
    end
  end

  test "should redirect to the login page when accessing the password reset form with an invalid token" do
    token = "invalid_token"

    get edit_password_reset_path(token)

    assert_redirected_to login_path
    follow_redirect!
    assert_flash :error, EXPECTED_PASSWORD_RESET_ERROR_FLASH
  end

  test "should redirect to the login page when accessing the password reset form with an expired token" do
    token = @user.generate_token_for(:password_reset)

    # Simulate the passage of one week
    travel PASSWORD_RESET_TOKEN_TTL + 1.minute
    get edit_password_reset_path(token)

    assert_redirected_to login_path
    follow_redirect!
    assert_flash :error, EXPECTED_PASSWORD_RESET_ERROR_FLASH
  end

  test "should request password reset email" do
    post password_reset_path, params: { user: { email: @user.email } }

    assert_redirected_to login_path
    follow_redirect!
    assert_flash :success, EXPECTED_FORGOT_PASSWORD_SUCCESS_FLASH
    assert_enqueued_email_with UserMailer, :password_reset_email, args: ->(args) { args[0] == @user }
  end

  test "should not send email for non-existent user" do
    post password_reset_path, params: { user: { email: "foo@example.com" } }

    assert_redirected_to login_path
    follow_redirect!
    assert_flash :success, EXPECTED_FORGOT_PASSWORD_SUCCESS_FLASH
    assert_enqueued_emails 0
  end

  test "should reset password" do
    token = @user.generate_token_for(:password_reset)

    patch edit_password_reset_path(token),
          params: { user: { password: "new_password", password_confirmation: "new_password" } }

    assert_redirected_to login_path
    follow_redirect!
    assert_flash :success, EXPECTED_PASSWORD_RESET_SUCCESS_FLASH
  end

  test "should redirect to the login page when submitting the password reset form with an invalid token" do
    token = "invalid_token"

    patch edit_password_reset_path(token),
          params: { user: { password: "new_password", password_confirmation: "new_password" } }

    assert_redirected_to login_path
    follow_redirect!
    assert_flash :error, EXPECTED_PASSWORD_RESET_ERROR_FLASH
  end

  test "should redirect to the login page when submitting the password reset form with an expired token" do
    token = @user.generate_token_for(:password_reset)

    # Simulate the passage of one week
    travel PASSWORD_RESET_TOKEN_TTL + 1.minute

    patch edit_password_reset_path(token),
          params: { user: { password: "new_password", password_confirmation: "new_password" } }

    assert_redirected_to login_path
    follow_redirect!
    assert_flash :error, EXPECTED_PASSWORD_RESET_ERROR_FLASH
  end
end

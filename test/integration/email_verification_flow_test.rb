require "test_helper"

class EmailVerificationFlowTest < ActionDispatch::IntegrationTest
  EXPECTED_EMAIL_VERIFICATION_REQUEST_SUCCESS_FLASH = "Verification email sent. Check your inbox."
  EXPECTED_EMAIL_VERIFICATION_SUCCESS_FLASH = "Email address verified."
  EXPECTED_EMAIL_VERIFICATION_ERROR_FLASH = "The email verification link has expired or invalid. Please request a new one."

  test "should verify email" do
    login
    token = @user.generate_token_for(:email_verification)

    assert_not @user.verified?
    get update_email_verification_path(token)

    assert_redirected_to root_path
    follow_redirect!
    assert_flash :success, EXPECTED_EMAIL_VERIFICATION_SUCCESS_FLASH
    assert @user.reload.verified?
  end

  test "should not verify email with invalid token" do
    login
    invalid_token = "invalid_token"

    assert_not @user.verified?
    get update_email_verification_path(invalid_token)

    assert_redirected_to root_path
    follow_redirect!
    assert_flash :error, EXPECTED_EMAIL_VERIFICATION_ERROR_FLASH
    assert_not @user.reload.verified?
  end

  test "should not verify email with expired token" do
    login
    token = @user.generate_token_for(:email_verification)


    # Simulate the passage of one week
    travel 1.week + 1.minute

    assert_not @user.verified?
    get update_email_verification_path(token)

    assert_redirected_to root_path
    follow_redirect!
    assert_flash :error, EXPECTED_EMAIL_VERIFICATION_ERROR_FLASH
    assert_not @user.reload.verified?
  end

  test "should resend verification email" do
    login

    post create_email_verification_path

    assert_redirected_to root_path
    follow_redirect!
    assert_flash :success, EXPECTED_EMAIL_VERIFICATION_REQUEST_SUCCESS_FLASH
    assert_enqueued_email_with UserMailer, :email_verification_email, args: -> (args) { args[0] == @user }
  end
end

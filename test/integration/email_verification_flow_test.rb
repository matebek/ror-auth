require "test_helper"

class EmailVerificationFlowTest < ActionDispatch::IntegrationTest
  test "should verify email" do
    login
    token = @user.generate_token_for(:email_verification)

    assert_not @user.verified?
    get update_email_verification_path(token)

    assert_redirected_to root_path
    assert_equal "Email address verified.", flash[:success]
    assert @user.reload.verified?
  end

  test "should not verify email with invalid token" do
    login
    invalid_token = "invalid_token"

    assert_not @user.verified?
    get update_email_verification_path(invalid_token)

    assert_redirected_to root_path
    assert_equal "The email verification link has expired or invalid. Please request a new one.", flash[:error]
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
    assert_equal "The email verification link has expired or invalid. Please request a new one.", flash[:error]
    assert_not @user.reload.verified?
  end

  test "should resend verification email" do
    login

    post create_email_verification_path

    assert_redirected_to root_path
    assert_equal "Verification email sent. Check your inbox.", flash[:success]
    assert_enqueued_email_with UserMailer, :email_verification_email, args: -> (args) { args[0] == @user }
  end
end

require "test_helper"

class UserAccountFlowTest < ActionDispatch::IntegrationTest
  EXPECTED_USER_ACCOUNT_CREATED_SUCCESS_FLASH = "User account created, happy hacking!"
  EXPECTED_USER_ACCOUNT_DELETED_SUCCESS_FLASH = "Your account has been deleted. See you on the other side."

  test "should access signup form" do
    get signup_path

    assert_response :success
    assert_select "h1", "Sign up"
    assert_select "form[action=?]", signup_path, method: :post do
      assert_select "input[placeholder=?]", "Please enter your name"
      assert_select "input[placeholder=?]", "Please enter your email address"
      assert_select "input[placeholder=?]", "Please enter your password"
      assert_select "input[placeholder=?]", "Please confirm your password"
      assert_select 'input[type=?][value=?]', "submit", "Sign up"
    end
  end

  test "should sign up" do
    get signup_path

    assert_response :success
    assert_select "h1", "Sign up"

    assert_difference("User.count") do
      post signup_path, params: { user: { name: "Jane", email: "jane@example.com", password: "secret", password_confirmation: "secret" } }

      assert_redirected_to root_path
      follow_redirect!
      assert_select "h1", "Welcome aboard, Jane"
      assert_flash :success, EXPECTED_USER_ACCOUNT_CREATED_SUCCESS_FLASH
    end

    new_user = User.find_by(email: "jane@example.com")
    assert_equal new_user, new_user.authenticate("secret")
    assert new_user.verified_at.nil?, "User should not be verified immediately after registration"
    assert_enqueued_email_with UserMailer, :email_verification_email, args: -> (args) { args[0] == new_user }
  end

  test "should delete user account" do
    login

    # Delete the authenticated user
    assert_difference("User.count", -1) do
      delete shutdown_path

      assert_redirected_to login_path
      follow_redirect!
      assert_select "h1", "Log in"
      assert_flash :success, EXPECTED_USER_ACCOUNT_DELETED_SUCCESS_FLASH
    end

    assert_nil User.find_by(id: @user.id), "User should be deleted"
  end
end

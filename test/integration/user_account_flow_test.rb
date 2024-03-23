require "test_helper"

class UserAccountFlowTest < ActionDispatch::IntegrationTest
  test "user should be able to sign up" do
    get signup_path

    assert_response :success
    assert_select "h1", "Sign up"

    assert_difference("User.count") do
      post signup_path, params: { user: { name: "Jane", email: "jane@example.com", password: "secret", password_confirmation: "secret" } }

      assert_redirected_to root_path
      follow_redirect!
      assert_select "h1", "Welcome aboard, Jane"
      assert_equal "User account created, happy hacking!", flash[:success]
    end

    new_user = User.find_by(email: "jane@example.com")
    assert_equal new_user, new_user.authenticate("secret")
    assert new_user.verified_at.nil?, "User should not be verified immediately after registration"
    assert_enqueued_email_with UserMailer, :email_verification_email, args: -> (args) { args[0] == new_user }
  end

  test "user should be able to delete account" do
    login

    # Delete the authenticated user
    assert_difference("User.count", -1) do
      delete shutdown_path

      assert_redirected_to login_path
      follow_redirect!
      assert_select "h1", "Log in"
      assert_equal "Your account has been deleted. See you on the other side.", flash[:success]
    end

    assert_nil User.find_by(id: @user.id), "User should be deleted"
  end
end

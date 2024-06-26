ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    setup do
      @user = users(:bob)
      @user_params = { email: @user.email, password: "correct_password" }
    end

    # Add more helper methods to be used by all tests here...
    def login(remember_me: false)
      post login_path, params: { user: { **@user_params, remember_me: remember_me ? "1" : "0" } }
      assert_redirected_to root_path
      follow_redirect!
    end

    def assert_flash(type, message, session = nil)
      flash_container = session ? session.flash : flash
      flash_assert_equal = session ? session.method(:assert_equal) : method(:assert_equal)
      flash_assert_select = session ? session.method(:assert_select) : method(:assert_select)

      flash_assert_equal.call(message, flash_container[type])
      flash_assert_select.call("div", message)
    end
  end
end

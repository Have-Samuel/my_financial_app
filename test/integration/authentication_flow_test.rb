require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "root redirects visitors to user sign in" do
    get root_url
    assert_redirected_to new_user_session_url
  end

  test "admin page redirects visitors to admin sign in" do
    get "/admin"
    assert_redirected_to new_admin_session_url
  end

  test "signed-in user sees the app root" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end

  test "signed-in admin sees the admin root and admin page" do
    sign_in admins(:one)
    get root_url
    assert_response :success
    get "/admin"
    assert_response :success
  end
end

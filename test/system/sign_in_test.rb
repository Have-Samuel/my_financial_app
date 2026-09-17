require "application_system_test_case"

class SignInTest < ApplicationSystemTestCase
  test "user signs in and lands on the dashboard" do
    visit new_user_session_path
    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password"
    click_button "Log in"

    assert_text "Current Balance"
    assert_current_path "/"
  end

  test "invalid credentials re-render the form with an error" do
    visit new_user_session_path
    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "wrong-password"
    click_button "Log in"

    assert_text "Invalid email or password"
    assert_current_path "/users/sign_in"
  end
end

require "test_helper"

class PotsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "visitor is redirected to sign in" do
    sign_out :user
    get pots_url
    assert_redirected_to new_user_session_url
  end

  test "index shows pots with progress" do
    get pots_url
    assert_response :success
    assert_includes response.body, "Vacation Fund"
    assert_includes response.body, "$130.00" # saved
    assert_includes response.body, "$2,000.00" # target
    assert_includes response.body, "Total Saved"
    assert_includes response.body, "Add Money"
    assert_includes response.body, "Withdraw"
  end

  test "does not list another user's pots" do
    users(:two).pots.create!(name: "Secret Stash", target_cents: 100_00)
    get pots_url
    assert_not_includes response.body, "Secret Stash"
  end

  test "creates a pot for the current user" do
    assert_difference -> { users(:one).pots.count }, 1 do
      post pots_url, params: { pot: {
        name: "Emergency Fund", target: "5000", color: "#277c78" } }
    end

    pot = users(:one).pots.order(:id).last
    assert_equal 500_000, pot.target_cents
    assert_redirected_to pots_url
  end

  test "rejects an invalid pot" do
    assert_no_difference -> { Pot.count } do
      post pots_url, params: { pot: { name: "", target: "", color: "" } }
    end
    assert_response :unprocessable_content
  end

  test "updates own pot" do
    patch pot_url(pots(:vacation)), params: { pot: {
      name: "Big Trip", target: "3000", color: "#c94736" } }
    pot = pots(:vacation).reload
    assert_equal "Big Trip", pot.name
    assert_equal 300_000, pot.target_cents
    assert_redirected_to pots_url
  end

  test "destroys own pot" do
    assert_difference -> { Pot.count }, -1 do
      delete pot_url(pots(:vacation))
    end
    assert_redirected_to pots_url
  end

  test "cannot edit another user's pot" do
    other = users(:two).pots.create!(name: "Not Yours", target_cents: 100_00)
    get edit_pot_url(other)
    assert_response :not_found
  end

  test "cannot delete another user's pot" do
    other = users(:two).pots.create!(name: "Not Yours", target_cents: 100_00)
    assert_no_difference -> { Pot.count } do
      delete pot_url(other)
    end
    assert_response :not_found
  end
end

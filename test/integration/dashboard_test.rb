require "test_helper"

class DashboardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "signed-in user sees the overview dashboard" do
    sign_in users(:one)
    get root_url
    assert_response :success

    assert_includes response.body, "Overview"
    assert_includes response.body, "Current Balance"
    assert_includes response.body, "$2,892.10" # fixture balance: 300000 - 8540 - 2250
    assert_includes response.body, "Income"
    assert_includes response.body, "Expenses"
    assert_includes response.body, "Pots"
    assert_includes response.body, "Budgets"
    assert_includes response.body, "Recurring Bills"
    assert_includes response.body, "Whole Foods" # recent transaction
  end

  test "signed-in user with no data sees empty states" do
    sign_in users(:two)
    get root_url
    assert_response :success

    assert_includes response.body, "$0.00"
    assert_includes response.body, "No transactions yet."
    assert_includes response.body, "No savings pots yet."
    assert_includes response.body, "No budgets yet."
  end
end

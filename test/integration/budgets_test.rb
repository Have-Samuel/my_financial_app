require "test_helper"

class BudgetsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "visitor is redirected to sign in" do
    sign_out :user
    get budgets_url
    assert_redirected_to new_user_session_url
  end

  test "index shows budgets with spending breakdown" do
    get budgets_url
    assert_response :success
    assert_includes response.body, "Budgets"
    assert_includes response.body, "Groceries"
    assert_includes response.body, "$400.00" # limit
    assert_includes response.body, "Maximum of"
    assert_includes response.body, "Spent"
    assert_includes response.body, "Remaining"
  end

  test "index shows latest spending transactions for the category" do
    get budgets_url
    assert_includes response.body, "Latest Spending"
    assert_includes response.body, "Whole Foods"
  end

  test "does not list another user's budgets" do
    users(:two).budgets.create!(category: users(:two).categories.create!(name: "Secret"), limit_cents: 999_00)
    get budgets_url
    assert_not_includes response.body, "Secret"
  end

  test "creates a budget for the current user" do
    assert_difference -> { users(:one).budgets.count }, 1 do
      post budgets_url, params: { budget: {
        category_id: categories(:entertainment).id, limit: "75.50", color: "#82c9d7" } }
    end

    budget = users(:one).budgets.order(:id).last
    assert_equal 7550, budget.limit_cents
    assert_redirected_to budgets_url
  end

  test "rejects a second budget for the same category" do
    assert_no_difference -> { Budget.count } do
      post budgets_url, params: { budget: {
        category_id: categories(:groceries).id, limit: "100", color: "#82c9d7" } }
    end
    assert_response :unprocessable_content
  end

  test "new form excludes already-budgeted categories" do
    get new_budget_url
    assert_response :success
    assert_no_match(/value="#{categories(:groceries).id}"/, response.body)
    assert_match(/value="#{categories(:entertainment).id}"/, response.body)
  end

  test "updates own budget" do
    patch budget_url(budgets(:groceries_budget)), params: { budget: {
      category_id: categories(:groceries).id, limit: "500", color: "#c94736" } }
    assert_equal 50_000, budgets(:groceries_budget).reload.limit_cents
    assert_redirected_to budgets_url
  end

  test "destroys own budget" do
    assert_difference -> { Budget.count }, -1 do
      delete budget_url(budgets(:groceries_budget))
    end
    assert_redirected_to budgets_url
  end

  test "cannot edit another user's budget" do
    other = users(:two).budgets.create!(
      category: users(:two).categories.create!(name: "Secret"), limit_cents: 999_00)

    get edit_budget_url(other)
    assert_response :not_found
  end

  test "cannot delete another user's budget" do
    other = users(:two).budgets.create!(
      category: users(:two).categories.create!(name: "Secret"), limit_cents: 999_00)

    assert_no_difference -> { Budget.count } do
      delete budget_url(other)
    end
    assert_response :not_found
  end
end

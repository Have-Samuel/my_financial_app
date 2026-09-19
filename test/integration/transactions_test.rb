require "test_helper"

class TransactionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "visitor is redirected to sign in" do
    sign_out :user
    get transactions_url
    assert_redirected_to new_user_session_url
  end

  test "index lists only the current user's transactions" do
    users(:two).transactions.create!(
      category: users(:two).categories.create!(name: "Stuff"),
      recipient: "Someone Else's Store",
      amount_cents: 999, direction: :expense, occurred_on: Date.current
    )

    get transactions_url
    assert_response :success
    assert_includes response.body, "Whole Foods"
    assert_not_includes response.body, "Someone Else's Store"
  end

  test "search filters by recipient, case-insensitive" do
    get transactions_url(q: "WHOLE")
    assert_includes response.body, "Whole Foods"
    assert_not_includes response.body, "AMC Theatres"
  end

  test "filters by category" do
    get transactions_url(category_id: categories(:entertainment).id)
    assert_includes response.body, "AMC Theatres"
    assert_not_includes response.body, "Whole Foods"
  end

  test "sorts by highest amount first" do
    get transactions_url(sort: "highest")
    assert response.body.index("Acme Corp Payroll") < response.body.index("Whole Foods")
  end

  test "sorts alphabetically" do
    get transactions_url(sort: "a-z")
    assert response.body.index("Acme Corp Payroll") < response.body.index("Whole Foods")
  end

  test "creates a transaction for the current user" do
    assert_difference -> { users(:one).transactions.count }, 1 do
      post transactions_url, params: { transaction: {
        recipient: "New Store", category_id: categories(:groceries).id,
        amount: "12.34", direction: "expense", occurred_on: Date.current.to_s } }
    end

    transaction = users(:one).transactions.order(:id).last
    assert_equal 1234, transaction.amount_cents
    assert_equal "New Store", transaction.recipient
    assert_redirected_to transactions_url
  end

  test "rejects an invalid transaction" do
    assert_no_difference -> { Transaction.count } do
      post transactions_url, params: { transaction: {
        recipient: "", category_id: nil, amount: "", direction: "", occurred_on: "" } }
    end
    assert_response :unprocessable_content
  end

  test "updates own transaction" do
    patch transaction_url(transactions(:grocery_run)), params: { transaction: {
      recipient: "Whole Foods Market", category_id: categories(:groceries).id,
      amount: "99.99", direction: "expense", occurred_on: Date.current.to_s } }

    assert_equal 9999, transactions(:grocery_run).reload.amount_cents
    assert_redirected_to transactions_url
  end

  test "destroys own transaction" do
    assert_difference -> { Transaction.count }, -1 do
      delete transaction_url(transactions(:grocery_run))
    end
    assert_redirected_to transactions_url
  end

  test "cannot edit another user's transaction" do
    other = users(:two).transactions.create!(
      category: users(:two).categories.create!(name: "Stuff"),
      recipient: "Not Yours", amount_cents: 100,
      direction: :expense, occurred_on: Date.current
    )

    get edit_transaction_url(other)
    assert_response :not_found
  end

  test "cannot delete another user's transaction" do
    other = users(:two).transactions.create!(
      category: users(:two).categories.create!(name: "Stuff"),
      recipient: "Not Yours", amount_cents: 100,
      direction: :expense, occurred_on: Date.current
    )

    assert_no_difference -> { Transaction.count } do
      delete transaction_url(other)
    end
    assert_response :not_found
  end
end

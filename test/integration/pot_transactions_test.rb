require "test_helper"

class PotTransactionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "deposit creates a positive ledger entry" do
    assert_difference -> { pots(:vacation).pot_transactions.count }, 1 do
      post pot_pot_transactions_url(pots(:vacation)), params: {
        pot_transaction: { kind: "deposit", amount: "50.00" } }
    end

    entry = pots(:vacation).pot_transactions.order(:id).last
    assert_equal 5000, entry.amount_cents
    assert_equal 18_000, pots(:vacation).reload.saved_cents # 13000 + 5000
    assert_redirected_to pots_url
  end

  test "withdrawal creates a negative ledger entry" do
    post pot_pot_transactions_url(pots(:vacation)), params: {
      pot_transaction: { kind: "withdrawal", amount: "30.00" } }

    entry = pots(:vacation).pot_transactions.order(:id).last
    assert_equal(-3000, entry.amount_cents)
    assert_equal 10_000, pots(:vacation).reload.saved_cents # 13000 - 3000
    assert_redirected_to pots_url
  end

  test "withdrawal cannot exceed the pot's savings" do
    assert_no_difference -> { PotTransaction.count } do
      post pot_pot_transactions_url(pots(:vacation)), params: {
        pot_transaction: { kind: "withdrawal", amount: "99999" } }
    end
    assert_response :unprocessable_content
  end

  test "deposit cannot exceed the user's available balance" do
    assert_no_difference -> { PotTransaction.count } do
      post pot_pot_transactions_url(pots(:vacation)), params: {
        pot_transaction: { kind: "deposit", amount: "999999" } }
    end
    assert_response :unprocessable_content
  end

  test "cannot add money to another user's pot" do
    other = users(:two).pots.create!(name: "Not Yours", target_cents: 100_00)
    assert_no_difference -> { PotTransaction.count } do
      post pot_pot_transactions_url(other), params: {
        pot_transaction: { kind: "deposit", amount: "10" } }
    end
    assert_response :not_found
  end

  test "new deposit form renders" do
    get new_pot_pot_transaction_url(pots(:vacation), kind: "deposit")
    assert_response :success
    assert_includes response.body, "Add Money to"
  end

  test "new withdrawal form renders" do
    get new_pot_pot_transaction_url(pots(:vacation), kind: "withdrawal")
    assert_response :success
    assert_includes response.body, "Withdraw from"
  end
end

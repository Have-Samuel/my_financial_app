require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "is valid with all required fields" do
    transaction = Transaction.new(
      user: users(:one), category: categories(:groceries),
      recipient: "Corner Store", amount_cents: 500,
      direction: :expense, occurred_on: Date.current
    )
    assert transaction.valid?
  end

  test "rejects zero and negative amounts" do
    [ 0, -100 ].each do |cents|
      transaction = transactions(:grocery_run).dup
      transaction.amount_cents = cents
      assert_not transaction.valid?
    end
  end

  test "direction enum scopes income and expense" do
    assert_includes Transaction.income, transactions(:paycheck)
    assert_includes Transaction.expense, transactions(:grocery_run)
    assert_not_includes Transaction.income, transactions(:grocery_run)
  end
end

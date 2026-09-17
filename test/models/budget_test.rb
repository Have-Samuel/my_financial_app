require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test "requires a positive limit" do
    budget = Budget.new(user: users(:two), category: categories(:groceries), limit_cents: 0)
    assert_not budget.valid?
  end

  test "only one budget per category per user" do
    budget = Budget.new(user: users(:one), category: categories(:groceries), limit_cents: 50000)
    assert_not budget.valid?
  end

  test "same category allowed for a different user" do
    budget = Budget.new(user: users(:two), category: categories(:groceries), limit_cents: 50000)
    assert budget.valid?
  end

  test "spent_this_month_cents only counts current-month expenses in the category" do
    budget = budgets(:groceries_budget)
    this_month = budget.user.transactions.expense
                       .where(category: budget.category, occurred_on: Date.current.all_month)
                       .sum(:amount_cents)
    assert_equal this_month, budget.spent_this_month_cents

    budget.user.transactions.create!(category: budget.category, recipient: "Old Groceries",
      amount_cents: 999, direction: :expense, occurred_on: 2.months.ago)
    budget.user.transactions.create!(category: budget.category, recipient: "Refund",
      amount_cents: 500, direction: :income, occurred_on: Date.current)

    assert_equal this_month, budget.spent_this_month_cents
  end
end

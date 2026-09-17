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
end

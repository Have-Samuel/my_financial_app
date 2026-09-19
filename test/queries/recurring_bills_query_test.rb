require "test_helper"

class RecurringBillsQueryTest < ActiveSupport::TestCase
  setup { @scope = users(:one).recurring_bills }

  test "search narrows by title" do
    results = RecurringBillsQuery.new(@scope, { q: "spark" }).results
    assert_equal [ recurring_bills(:electric) ], results.to_a
  end

  test "sorts by highest amount" do
    results = RecurringBillsQuery.new(@scope, { sort: "highest" }).results
    assert_equal recurring_bills(:rent), results.first
  end

  test "default sort is due soonest" do
    results = RecurringBillsQuery.new(@scope, {}).results
    days = results.map(&:days_until_due)
    assert_equal days.sort, days
  end

  test "unknown sort falls back to due_soon" do
    assert_equal "due_soon", RecurringBillsQuery.new(@scope, { sort: "bogus" }).sort
  end
end

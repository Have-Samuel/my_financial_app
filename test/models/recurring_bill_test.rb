require "test_helper"

class RecurringBillTest < ActiveSupport::TestCase
  test "due_day must be between 1 and 31" do
    [ 0, 32 ].each do |day|
      bill = recurring_bills(:electric).dup
      bill.due_day = day
      assert_not bill.valid?
    end
  end

  test "status enum" do
    assert recurring_bills(:electric).pending?
    assert recurring_bills(:rent).paid?
  end

  test "days_until_due rolls past due days into next month" do
    bill = recurring_bills(:electric) # due_day 15
    assert_equal 3, bill.days_until_due(Date.new(2026, 9, 12))
    assert_equal 0, bill.days_until_due(Date.new(2026, 9, 15))
    assert_equal 29, bill.days_until_due(Date.new(2026, 9, 16)) # next due Oct 15
  end

  test "due_soon? inside the window, overdue always, paid never" do
    bill = recurring_bills(:electric) # pending, due_day 15
    assert bill.due_soon?(Date.new(2026, 9, 10))
    assert_not bill.due_soon?(Date.new(2026, 9, 1))

    bill.status = :overdue
    assert bill.due_soon?

    bill.status = :paid
    assert_not bill.due_soon?
  end
end

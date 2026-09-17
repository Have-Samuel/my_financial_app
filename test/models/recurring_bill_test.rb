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
end

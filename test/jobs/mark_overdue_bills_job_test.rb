require "test_helper"

class MarkOverdueBillsJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "marks pending bills whose due day has passed as overdue" do
    travel_to Date.new(2026, 9, 17) do
      assert_equal "pending", recurring_bills(:electric).status

      MarkOverdueBillsJob.perform_now

      assert_equal "overdue", recurring_bills(:electric).reload.status # due 15th
      assert_equal "paid", recurring_bills(:rent).reload.status        # paid bills untouched
    end
  end

  test "leaves pending bills not yet due this month" do
    travel_to Date.new(2026, 9, 10) do
      MarkOverdueBillsJob.perform_now
      assert_equal "pending", recurring_bills(:electric).reload.status # due 15th
    end
  end

  test "is idempotent" do
    travel_to Date.new(2026, 9, 17) do
      MarkOverdueBillsJob.perform_now
      assert_no_changes -> { recurring_bills(:electric).reload.status } do
        MarkOverdueBillsJob.perform_now
      end
    end
  end
end

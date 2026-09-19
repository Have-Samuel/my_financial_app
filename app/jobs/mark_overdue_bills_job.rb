class MarkOverdueBillsJob < ApplicationJob
  queue_as :default

  # A pending bill becomes overdue once this month's due day has
  # passed without payment. Paid bills and bills still upcoming
  # (due_day >= today) are untouched.
  def perform(today = Date.current)
    RecurringBill.pending.where("due_day < ?", today.day)
               .update_all(status: :overdue)
  end
end

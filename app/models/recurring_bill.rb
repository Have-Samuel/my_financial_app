class RecurringBill < ApplicationRecord
  belongs_to :user

  enum :status, { pending: 0, paid: 1, overdue: 2 }

  validates :title, presence: true
  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :due_day, presence: true, inclusion: { in: 1..31 }

  DUE_SOON_WINDOW_DAYS = 7

  # Days until the bill is next due. due_day is day-of-month, so a
  # due day that already passed this month rolls into next month.
  def days_until_due(today = Date.current)
    due = today + (due_day - today.day)
    due = due.next_month if due < today
    (due - today).to_i
  end

  def due_soon?(today = Date.current)
    overdue? || (pending? && days_until_due(today) <= DUE_SOON_WINDOW_DAYS)
  end
end

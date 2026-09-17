class RecurringBill < ApplicationRecord
  belongs_to :user

  enum :status, { pending: 0, paid: 1, overdue: 2 }

  validates :title, presence: true
  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :due_day, presence: true, inclusion: { in: 1..31 }
end

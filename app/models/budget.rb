class Budget < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :limit_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :category_id, uniqueness: { scope: :user_id }

  def spent_this_month_cents(date = Date.current)
    user.transactions.expense
        .where(category: category, occurred_on: date.all_month)
        .sum(:amount_cents)
  end

  def remaining_this_month_cents(date = Date.current)
    limit_cents - spent_this_month_cents(date)
  end

  # Latest expense transactions feeding this budget's spend.
  def latest_spending(limit = 3)
    user.transactions.expense.where(category: category).chronological.limit(limit)
  end

  # Virtual attribute so forms can accept dollar amounts while the
  # column stays integer cents.
  def limit
    limit_cents.to_f / 100
  end

  def limit=(value)
    self.limit_cents = (value.to_f * 100).round
  end
end

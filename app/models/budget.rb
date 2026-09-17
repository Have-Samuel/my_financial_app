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
end

class Budget < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :limit_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :category_id, uniqueness: { scope: :user_id }

  def spent_this_month_cents(date = Date.current)
    @spent_cache ||= {}
    @spent_cache[date] ||= user.transactions.expense
        .where(category: category, occurred_on: date.all_month)
        .sum(:amount_cents)
  end

  # Fills the memo with a batch-computed value — see .preload_monthly_spend.
  def preload_monthly_spend(cents, date = Date.current)
    (@spent_cache ||= {})[date] = cents
  end

  # Batch-loads spend for a whole collection in one grouped query
  # instead of one query per budget.
  def self.preload_monthly_spend(budgets, date = Date.current)
    budgets = budgets.to_a
    return budgets if budgets.empty?

    spend = budgets.first.user.transactions.expense
                   .where(occurred_on: date.all_month, category_id: budgets.map(&:category_id))
                   .group(:category_id)
                   .sum(:amount_cents)
    budgets.each { |b| b.preload_monthly_spend(spend[b.category_id] || 0, date) }
    budgets
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
    limit_cents && limit_cents / 100.0
  end

  def limit=(value)
    self.limit_cents = (value.to_f * 100).round
  end
end

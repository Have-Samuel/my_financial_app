class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Declaration order matters: transactions and budgets reference
  # categories, so they must be destroyed first on user destroy.
  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :pots, dependent: :destroy
  has_many :recurring_bills, dependent: :destroy
  has_many :categories, dependent: :destroy

  validates :name, presence: true

  # Balance is derived from the ledger: income minus expenses.
  # An "opening balance" income transaction seeds the starting point.
  def balance_cents
    transactions.income.sum(:amount_cents) - transactions.expense.sum(:amount_cents)
  end

  def monthly_income_cents(date = Date.current)
    transactions.income.where(occurred_on: date.all_month).sum(:amount_cents)
  end

  def monthly_expenses_cents(date = Date.current)
    transactions.expense.where(occurred_on: date.all_month).sum(:amount_cents)
  end

  def total_saved_in_pots_cents
    PotTransaction.joins(:pot).where(pots: { user_id: id }).sum(:amount_cents)
  end

  # Spendable cash: the ledger balance minus money parked in pots.
  # Matches the reference semantics where adding to a pot reduces
  # the current balance and withdrawing adds it back.
  def available_balance_cents
    balance_cents - total_saved_in_pots_cents
  end
end

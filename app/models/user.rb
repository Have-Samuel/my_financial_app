class User < ApplicationRecord
  # Seeded on sign-up so a fresh account can create transactions
  # immediately — transactions require a category.
  DEFAULT_CATEGORIES = [
    { name: "Entertainment",   color: "#277C78" },
    { name: "Bills",           color: "#82C9D7" },
    { name: "Groceries",       color: "#F2CDAC" },
    { name: "Dining Out",      color: "#626070" },
    { name: "Transportation",  color: "#C94736" },
    { name: "Personal Care",   color: "#826CB0" },
    { name: "Education",       color: "#597C7C" },
    { name: "Lifestyle",       color: "#93674F" },
    { name: "Shopping",        color: "#3F82B2" },
    { name: "General",         color: "#97A0AC" }
  ].freeze

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

  after_create :seed_default_categories

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

  private

  # find_or_create_by! keeps it idempotent when backfilling users
  # that already have some of these categories.
  def seed_default_categories
    DEFAULT_CATEGORIES.each do |attrs|
      categories.find_or_create_by!(name: attrs[:name]) do |category|
        category.color = attrs[:color]
      end
    end
  end
end

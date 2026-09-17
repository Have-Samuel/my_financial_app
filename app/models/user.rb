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
end

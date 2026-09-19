class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @balance_cents = current_user.available_balance_cents
    @income_cents = current_user.monthly_income_cents
    @expenses_cents = current_user.monthly_expenses_cents
    @recent_transactions = current_user.transactions
                                       .includes(:category)
                                       .chronological.limit(5)
    @pots = Pot.preload_saved_cents(current_user.pots)
    @budgets = Budget.preload_monthly_spend(current_user.budgets.includes(:category))
    @bills = current_user.recurring_bills
  end
end

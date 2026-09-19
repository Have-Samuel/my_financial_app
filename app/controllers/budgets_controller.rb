class BudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_budget, only: %i[edit update destroy]
  before_action :set_available_categories, only: %i[new create edit update]

  def index
    @budgets = Budget.preload_monthly_spend(current_user.budgets.includes(:category))
  end

  def new
    @budget = current_user.budgets.build
  end

  def create
    @budget = current_user.budgets.build(budget_params)

    if @budget.save
      redirect_to budgets_path, notice: "Budget created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @budget.update(budget_params)
      redirect_to budgets_path, notice: "Budget updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @budget.destroy
    redirect_to budgets_path, notice: "Budget deleted."
  end

  private

  def set_budget
    @budget = current_user.budgets.find(params[:id])
  end

  # A category can only have one budget, so the picker excludes
  # already-budgeted categories (except the one being edited).
  def set_available_categories
    used = current_user.budgets.where.not(id: @budget&.id).select(:category_id)
    @available_categories = current_user.categories.where.not(id: used).order(:name)
  end

  def budget_params
    params.require(:budget).permit(:category_id, :limit, :color)
  end
end

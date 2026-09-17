class RecurringBillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bill, only: %i[edit update destroy]

  def index
    @query = RecurringBillsQuery.new(current_user.recurring_bills, index_params)
    @bills = @query.results
    @all_bills = current_user.recurring_bills
  end

  def new
    @bill = current_user.recurring_bills.build
  end

  def create
    @bill = current_user.recurring_bills.build(bill_params)

    if @bill.save
      redirect_to recurring_bills_path, notice: "Recurring bill created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @bill.update(bill_params)
      redirect_to recurring_bills_path, notice: "Recurring bill updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @bill.destroy
    redirect_to recurring_bills_path, notice: "Recurring bill deleted."
  end

  private

  def set_bill
    @bill = current_user.recurring_bills.find(params[:id])
  end

  def index_params
    params.permit(:q, :sort)
  end

  def bill_params
    params.require(:recurring_bill).permit(:title, :amount, :due_day, :status)
  end
end

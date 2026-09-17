class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: %i[edit update destroy]
  before_action :set_categories, only: %i[index new create edit update]

  def index
    @query = TransactionsQuery.new(current_user.transactions.includes(:category), index_params)
    @transactions = @query.results
  end

  def new
    @transaction = current_user.transactions.build(occurred_on: Date.current)
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "Transaction updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_path, notice: "Transaction deleted."
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def set_categories
    @categories = current_user.categories.order(:name)
  end

  def index_params
    params.permit(:q, :category_id, :sort, :page)
  end

  def transaction_params
    params.require(:transaction).permit(:recipient, :category_id, :amount, :direction, :occurred_on)
  end
end

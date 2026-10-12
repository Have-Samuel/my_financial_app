class TransactionsController < ApplicationController
  before_action :authenticate_user! # Ensures that only authenticated users can access the transactions actions
  before_action :set_transaction, only: %i[edit update destroy] # Sets the @transaction instance variable for the edit, update, and destroy actions by finding the transaction belonging to the current user based on the provided ID.
  before_action :set_categories, only: %i[index new create edit update] # Sets the @categories instance variable to the current user's categories, ordered by name. This is used in the index, new, create, edit, and update actions to provide a list of categories for transaction selection.

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
  # Sets the @categories instance variable to the current user's categories, ordered by name. This is used in the index, new, create, edit, and update actions to provide a list of categories for transaction selection.
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

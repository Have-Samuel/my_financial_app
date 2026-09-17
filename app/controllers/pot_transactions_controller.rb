class PotTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pot

  def new
    @pot_transaction = @pot.pot_transactions.build
    @kind = kind_param
  end

  def create
    @kind = kind_param
    cents = (params.dig(:pot_transaction, :amount).to_f * 100).round
    cents = -cents if @kind == "withdrawal"
    @pot_transaction = @pot.pot_transactions.build(
      amount_cents: cents, transacted_on: Date.current
    )

    if @pot_transaction.save
      action = @kind == "withdrawal" ? "Withdrew" : "Added"
      redirect_to pots_path, notice: "#{action} #{helpers.money(cents.abs)} #{@kind == 'withdrawal' ? 'from' : 'to'} #{@pot.name}."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_pot
    @pot = current_user.pots.find(params[:pot_id])
  end

  def kind_param
    params.dig(:pot_transaction, :kind) == "withdrawal" || params[:kind] == "withdrawal" ? "withdrawal" : "deposit"
  end
end

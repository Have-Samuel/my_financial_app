class PotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pot, only: %i[edit update destroy]

  def index
    @pots = Pot.preload_saved_cents(current_user.pots)
  end

  def new
    @pot = current_user.pots.build
  end

  def create
    @pot = current_user.pots.build(pot_params)

    if @pot.save
      redirect_to pots_path, notice: "Pot created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @pot.update(pot_params)
      redirect_to pots_path, notice: "Pot updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @pot.destroy
    redirect_to pots_path, notice: "Pot deleted."
  end

  private

  def set_pot
    @pot = current_user.pots.find(params[:id])
  end

  def pot_params
    params.require(:pot).permit(:name, :target, :color)
  end
end

class Pot < ApplicationRecord
  belongs_to :user
  has_many :pot_transactions, dependent: :destroy

  validates :name, presence: true
  validates :target_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  # Saved amount is derived from the ledger — the ledger is the
  # single source of truth, so it can never drift.
  def saved_cents
    pot_transactions.sum(:amount_cents)
  end

  # Virtual attribute so forms can accept dollar amounts while the
  # column stays integer cents.
  def target
    target_cents && target_cents / 100.0
  end

  def target=(value)
    self.target_cents = (value.to_f * 100).round
  end
end

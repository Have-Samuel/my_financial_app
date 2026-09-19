class Pot < ApplicationRecord
  belongs_to :user
  has_many :pot_transactions, dependent: :destroy

  validates :name, presence: true
  validates :target_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  # Saved amount is derived from the ledger — the ledger is the
  # single source of truth, so it can never drift.
  def saved_cents
    @saved_cents ||= pot_transactions.sum(:amount_cents)
  end

  # Fills the memo with a batch-computed value — see .preload_saved_cents.
  def preload_saved_cents(cents)
    @saved_cents = cents
  end

  # Batch-loads savings for a whole collection in one grouped query
  # instead of one query per pot.
  def self.preload_saved_cents(pots)
    pots = pots.to_a
    return pots if pots.empty?

    saved = PotTransaction.where(pot_id: pots.map(&:id))
                          .group(:pot_id)
                          .sum(:amount_cents)
    pots.each { |p| p.preload_saved_cents(saved[p.id] || 0) }
    pots
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

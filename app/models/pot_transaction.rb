class PotTransaction < ApplicationRecord
  belongs_to :pot

  validates :amount_cents, presence: true,
            numericality: { only_integer: true, other_than: 0 }
  validates :transacted_on, presence: true
end

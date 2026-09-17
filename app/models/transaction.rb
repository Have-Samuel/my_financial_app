class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :direction, { expense: 0, income: 1 }

  validates :recipient, presence: true
  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :occurred_on, presence: true

  scope :chronological, -> { order(occurred_on: :desc, created_at: :desc) }
end

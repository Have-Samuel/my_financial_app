class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum :direction, { expense: 0, income: 1 }

  validates :recipient, presence: true
  validates :amount_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :occurred_on, presence: true

  scope :chronological, -> { order(occurred_on: :desc, created_at: :desc) }
  scope :search, ->(query) { where("recipient ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :in_category, ->(category_id) { where(category_id: category_id) }

  # Virtual attribute so forms can accept dollar amounts while the
  # column stays integer cents.
  def amount
    amount_cents.to_f / 100
  end

  def amount=(value)
    self.amount_cents = (value.to_f * 100).round
  end
end

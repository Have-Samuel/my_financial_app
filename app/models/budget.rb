class Budget < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :limit_cents, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :category_id, uniqueness: { scope: :user_id }
end

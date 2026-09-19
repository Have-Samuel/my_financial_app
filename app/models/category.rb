class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error
  has_many :budgets, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
end

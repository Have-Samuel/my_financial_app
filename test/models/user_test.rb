require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with name, email, and password" do
    user = User.new(name: "Ada Lovelace", email: "ada@example.com", password: "secret123")
    assert user.valid?
  end

  test "requires a name" do
    user = User.new(email: "noname@example.com", password: "secret123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "rejects duplicate emails case-insensitively" do
    User.create!(name: "Ada", email: "ada@example.com", password: "secret123")
    user = User.new(name: "Bob", email: "ADA@example.com", password: "secret123")
    assert_not user.valid?
  end

  test "balance_cents is income minus expenses" do
    # fixtures: 300000 income, 8540 + 2250 expenses
    assert_equal 289210, users(:one).balance_cents
  end

  test "balance_cents is zero with no transactions" do
    assert_equal 0, users(:two).balance_cents
  end

  test "monthly_income_cents only counts the current month" do
    user = users(:one)
    expected = user.transactions.income
                   .where(occurred_on: Date.current.all_month)
                   .sum(:amount_cents)

    user.transactions.create!(category: categories(:groceries), recipient: "Old Pay",
      amount_cents: 50_000, direction: :income, occurred_on: 2.months.ago)

    assert_equal expected, user.reload.monthly_income_cents
  end

  test "available_balance_cents subtracts pot savings" do
    # balance 289210 minus 13000 saved in the vacation pot
    assert_equal 276_210, users(:one).available_balance_cents
  end
end

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
end

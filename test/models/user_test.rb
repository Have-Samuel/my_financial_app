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
end

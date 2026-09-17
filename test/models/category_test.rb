require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "requires a name" do
    category = Category.new(user: users(:one))
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "name must be unique per user" do
    category = Category.new(user: users(:one), name: "Groceries")
    assert_not category.valid?
  end

  test "same name is allowed for a different user" do
    category = Category.new(user: users(:two), name: "Groceries")
    assert category.valid?
  end
end

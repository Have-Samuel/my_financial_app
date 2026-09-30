require "test_helper"

class CategoriesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "visitor is redirected to sign in" do
    sign_out :user
    get categories_url
    assert_redirected_to new_user_session_url
  end

  test "index lists the current user's categories" do
    get categories_url
    assert_response :success
    assert_includes response.body, "Groceries"
    assert_includes response.body, "Entertainment"
  end

  test "does not list another user's categories" do
    users(:two).categories.create!(name: "Secret Label")
    get categories_url
    assert_not_includes response.body, "Secret Label"
  end

  test "creates a category for the current user" do
    assert_difference -> { users(:one).categories.count }, 1 do
      post categories_url, params: { category: { name: "Pets", color: "#3f82b2" } }
    end

    category = users(:one).categories.order(:id).last
    assert_equal "Pets", category.name
    assert_equal "#3f82b2", category.color
    assert_redirected_to categories_url
  end

  test "rejects a duplicate category name for the same user" do
    assert_no_difference -> { Category.count } do
      post categories_url, params: { category: { name: "Groceries", color: "#3f82b2" } }
    end
    assert_response :unprocessable_content
  end

  test "updates own category" do
    patch category_url(categories(:entertainment)), params: { category: {
      name: "Fun", color: "#c94736" } }
    assert_equal "Fun", categories(:entertainment).reload.name
    assert_redirected_to categories_url
  end

  test "destroys an unused category" do
    category = users(:one).categories.create!(name: "Temporary")
    assert_difference -> { Category.count }, -1 do
      delete category_url(category)
    end
    assert_redirected_to categories_url
  end

  test "cannot delete a category that still has transactions" do
    assert_no_difference -> { Category.count } do
      delete category_url(categories(:groceries))
    end
    assert_redirected_to categories_url
    assert_equal "Cannot delete record because dependent transactions exist",
                 flash[:alert]
  end

  test "cannot edit another user's category" do
    other = users(:two).categories.create!(name: "Secret")
    get edit_category_url(other)
    assert_response :not_found
  end

  test "cannot delete another user's category" do
    other = users(:two).categories.create!(name: "Secret")
    assert_no_difference -> { Category.count } do
      delete category_url(other)
    end
    assert_response :not_found
  end
end

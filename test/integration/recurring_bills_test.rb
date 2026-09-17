require "test_helper"

class RecurringBillsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "visitor is redirected to sign in" do
    sign_out :user
    get recurring_bills_url
    assert_redirected_to new_user_session_url
  end

  test "index shows bills with totals and summary" do
    get recurring_bills_url
    assert_response :success
    assert_includes response.body, "Spark Electric"
    assert_includes response.body, "Monthly Rent"
    assert_includes response.body, "Total Bills"
    assert_includes response.body, "$1,600.00" # 10000 + 150000
    assert_includes response.body, "Paid Bills"
    assert_includes response.body, "Total Upcoming"
    assert_includes response.body, "Due Soon"
    assert_includes response.body, "Monthly - 15th"
  end

  test "does not list another user's bills" do
    users(:two).recurring_bills.create!(
      title: "Secret Bill", amount_cents: 100, due_day: 5)
    get recurring_bills_url
    assert_not_includes response.body, "Secret Bill"
  end

  test "search filters by title" do
    get recurring_bills_url(q: "spark")
    assert_includes response.body, "Spark Electric"
    assert_not_includes response.body, "Monthly Rent"
  end

  test "sorts by highest amount" do
    get recurring_bills_url(sort: "highest")
    assert response.body.index("Monthly Rent") < response.body.index("Spark Electric")
  end

  test "creates a bill for the current user" do
    assert_difference -> { users(:one).recurring_bills.count }, 1 do
      post recurring_bills_url, params: { recurring_bill: {
        title: "Phone Plan", amount: "49.99", due_day: 12, status: "pending" } }
    end

    bill = users(:one).recurring_bills.order(:id).last
    assert_equal 4999, bill.amount_cents
    assert_redirected_to recurring_bills_url
  end

  test "rejects an invalid bill" do
    assert_no_difference -> { RecurringBill.count } do
      post recurring_bills_url, params: { recurring_bill: {
        title: "", amount: "", due_day: 45, status: "pending" } }
    end
    assert_response :unprocessable_content
  end

  test "updates own bill" do
    patch recurring_bill_url(recurring_bills(:electric)), params: { recurring_bill: {
      title: "Spark Premium", amount: "120.00", due_day: 15, status: "paid" } }

    bill = recurring_bills(:electric).reload
    assert_equal "Spark Premium", bill.title
    assert_equal 12_000, bill.amount_cents
    assert bill.paid?
    assert_redirected_to recurring_bills_url
  end

  test "destroys own bill" do
    assert_difference -> { RecurringBill.count }, -1 do
      delete recurring_bill_url(recurring_bills(:electric))
    end
    assert_redirected_to recurring_bills_url
  end

  test "cannot edit another user's bill" do
    other = users(:two).recurring_bills.create!(
      title: "Not Yours", amount_cents: 100, due_day: 5)
    get edit_recurring_bill_url(other)
    assert_response :not_found
  end

  test "cannot delete another user's bill" do
    other = users(:two).recurring_bills.create!(
      title: "Not Yours", amount_cents: 100, due_day: 5)
    assert_no_difference -> { RecurringBill.count } do
      delete recurring_bill_url(other)
    end
    assert_response :not_found
  end
end

require "test_helper"

class TransactionsQueryTest < ActiveSupport::TestCase
  setup { @scope = users(:one).transactions }

  test "search narrows by recipient" do
    results = TransactionsQuery.new(@scope, { q: "whole" }).results
    assert_equal [ transactions(:grocery_run) ], results.to_a
  end

  test "in_category narrows by category" do
    results = TransactionsQuery.new(@scope, { category_id: categories(:entertainment).id }).results
    assert_equal [ transactions(:movie_night) ], results.to_a
  end

  test "sorts by highest amount" do
    results = TransactionsQuery.new(@scope, { sort: "highest" }).results
    assert_equal transactions(:paycheck), results.first
  end

  test "unknown sort falls back to latest" do
    query = TransactionsQuery.new(@scope, { sort: "DROP TABLE" })
    assert_equal "latest", query.sort
    assert_equal transactions(:movie_night), query.results.first # most recent fixture
  end

  test "paginates results" do
    user = users(:two)
    category = user.categories.create!(name: "Stuff")
    12.times do |i|
      user.transactions.create!(
        category: category, recipient: "Store #{i}",
        amount_cents: 100, direction: :expense, occurred_on: Date.current
      )
    end

    query = TransactionsQuery.new(user.transactions, {})
    assert_equal 10, query.results.size
    assert_equal 2, query.total_pages

    page_two = TransactionsQuery.new(user.transactions, { page: "1" })
    assert_equal 2, page_two.results.size
  end
end

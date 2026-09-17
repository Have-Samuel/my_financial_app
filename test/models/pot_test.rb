require "test_helper"

class PotTest < ActiveSupport::TestCase
  test "saved_cents derives from the ledger" do
    assert_equal 13000, pots(:vacation).saved_cents
  end

  test "saved_cents is zero with no ledger entries" do
    pot = Pot.create!(user: users(:two), name: "New Pot", target_cents: 10000)
    assert_equal 0, pot.saved_cents
  end
end

require "test_helper"

class PotTransactionTest < ActiveSupport::TestCase
  test "rejects a zero amount" do
    entry = PotTransaction.new(pot: pots(:vacation), amount_cents: 0, transacted_on: Date.current)
    assert_not entry.valid?
  end

  test "accepts signed amounts for deposits and withdrawals" do
    [ 500, -500 ].each do |cents|
      entry = PotTransaction.new(pot: pots(:vacation), amount_cents: cents, transacted_on: Date.current)
      assert entry.valid?
    end
  end
end

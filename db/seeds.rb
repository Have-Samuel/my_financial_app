# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding demo data..."

user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.name = "Nicholas"
  u.password = "password123"
  u.password_confirmation = "password123"
end

# --- Categories -------------------------------------------------------------
CATEGORY_DEFAULTS = [
  { name: "Entertainment",   color: "#277C78" },
  { name: "Bills",           color: "#82C9D7" },
  { name: "Groceries",       color: "#F2CDAC" },
  { name: "Dining Out",      color: "#626070" },
  { name: "Transportation",  color: "#C94736" },
  { name: "Personal Care",   color: "#826CB0" },
  { name: "Education",       color: "#597C7C" },
  { name: "Lifestyle",       color: "#93674F" },
  { name: "Shopping",        color: "#3F82B2" },
  { name: "General",         color: "#97A0AC" }
].freeze

categories = CATEGORY_DEFAULTS.each_with_object({}) do |attrs, hash|
  hash[attrs[:name]] = user.categories.find_or_create_by!(name: attrs[:name]) do |c|
    c.color = attrs[:color]
  end
end

# Domain data is only seeded once — rerunning db:seed won't duplicate rows.
if user.transactions.exists?
  puts "Demo user already has data; skipping."
  return
end

# --- Transactions -------------------------------------------------------------
# [recipient, category, amount_cents, direction, days_ago, avatar]
TRANSACTIONS = [
  # Income
  [ "Opening Balance",        "General",        250_000, :income,  75, nil ],
  [ "Acme Corp Payroll",      "General",        320_000, :income,  45, "Logo 1.jpg" ],
  [ "Acme Corp Payroll",      "General",        320_000, :income,  15, "Logo 1.jpg" ],
  [ "Upwork Contract",        "General",         85_000, :income,  20, "Person 2.jpg" ],
  [ "Design Consultation",    "General",         42_000, :income,   8, "Person 3.jpg" ],

  # Groceries
  [ "Whole Foods Market",     "Groceries",        8_540, :expense,  1, "Logo 2.jpg" ],
  [ "Farmers Market",         "Groceries",        3_480, :expense,  6, "Person 5.jpg" ],
  [ "Trader Joe's",           "Groceries",        6_230, :expense,  4, "Logo 3.jpg" ],
  [ "Costco",                 "Groceries",       14_575, :expense, 12, "Logo 4.jpg" ],
  [ "Whole Foods Market",     "Groceries",        7_120, :expense, 25, "Logo 2.jpg" ],
  [ "Trader Joe's",           "Groceries",        5_560, :expense, 38, "Logo 3.jpg" ],

  # Dining Out
  [ "Chipotle",               "Dining Out",       1_425, :expense,  2, "Logo 5.jpg" ],
  [ "Starbucks",              "Dining Out",         675, :expense,  3, "Logo 7.jpg" ],
  [ "Olive Garden",           "Dining Out",       5_890, :expense,  9, "Logo 6.jpg" ],
  [ "Tony's Pizzeria",        "Dining Out",       3_240, :expense, 17, "Logo 8.jpg" ],

  # Entertainment
  [ "AMC Theatres",           "Entertainment",    2_250, :expense,  5, "Logo 9.jpg" ],
  [ "Steam",                  "Entertainment",    5_999, :expense, 14, "Logo 10.jpg" ],
  [ "Spotify",                "Entertainment",    1_099, :expense, 21, "Logo 11.jpg" ],
  [ "Netflix",                "Entertainment",    1_549, :expense, 30, "Logo 12.jpg" ],

  # Transportation
  [ "Uber",                   "Transportation",   1_875, :expense,  6, "Logo 13.jpg" ],
  [ "Shell",                  "Transportation",   4_820, :expense, 11, "Logo 14.jpg" ],
  [ "Metro Transit Card",     "Transportation",   3_400, :expense, 28, "Logo 15.jpg" ],

  # Personal Care / Education / Shopping
  [ "CVS Pharmacy",           "Personal Care",    2_345, :expense,  7, "Person 4.jpg" ],
  [ "Iron Gym Membership",    "Personal Care",    4_500, :expense, 15, "Logo 15.jpg" ],
  [ "Udemy Course",           "Education",        8_999, :expense, 19, "Logo 10.jpg" ],
  [ "Amazon",                 "Shopping",        12_999, :expense, 10, "Logo 11.jpg" ],
  [ "Target",                 "Shopping",         7_630, :expense, 22, "Logo 12.jpg" ],

  # Bills paid out of the ledger
  [ "Monthly Rent",           "Bills",          150_000, :expense, 32, "Logo 15.jpg" ],
  [ "Spark Electric",         "Bills",           11_240, :expense, 16, "Logo 13.jpg" ],
  [ "AquaFlow Water Utility", "Bills",            4_560, :expense, 18, "Logo 14.jpg" ],
  [ "Verizon Phone Bill",     "Bills",            6_500, :expense, 24, "Logo 13.jpg" ]
].freeze

TRANSACTIONS.each do |recipient, category, cents, direction, days_ago, avatar|
  user.transactions.create!(
    recipient: recipient,
    category: categories.fetch(category),
    amount_cents: cents,
    direction: direction,
    occurred_on: days_ago.days.ago.to_date,
    avatar: avatar
  )
end

# --- Budgets ------------------------------------------------------------------
[
  [ "Entertainment",  5_000, "#277C78" ],
  [ "Dining Out",     7_500, "#F2CDAC" ],
  [ "Groceries",     40_000, "#626070" ]
].each do |category_name, limit_cents, color|
  user.budgets.create!(
    category: categories.fetch(category_name),
    limit_cents: limit_cents,
    color: color
  )
end

# --- Pots (funded via the PotTransaction ledger) --------------------------------
# [name, target_cents, color, [deposit/withdrawal cents, days_ago]]
POTS = [
  [ "Savings",        200_000, "#277C78", [ [ 10_000, 40 ], [ 5_900, 20 ] ] ],
  [ "Concert Ticket",  15_000, "#626070", [ [ 7_500, 30 ], [ 3_500, 10 ] ] ],
  [ "Gift",             6_000, "#82C9D7", [ [ 4_000, 15 ] ] ],
  [ "New Laptop",     100_000, "#F2CDAC", [ [ 1_000, 5 ] ] ]
].freeze

POTS.each do |name, target_cents, color, entries|
  pot = user.pots.create!(name: name, target_cents: target_cents, color: color)
  entries.each do |cents, days_ago|
    pot.pot_transactions.create!(amount_cents: cents, transacted_on: days_ago.days.ago.to_date)
  end
end

# --- Recurring Bills ------------------------------------------------------------
# [title, amount_cents, due_day, status, avatar]
BILLS = [
  [ "Spark Electric Solutions",  10_000,  2, :paid,     "Logo 13.jpg" ],
  [ "Serenity Spa & Wellness",    3_000,  3, :paid,     "Person 6.jpg" ],
  [ "Elevate Education",          5_000,  4, :pending,  "Logo 10.jpg" ],
  [ "Pixel Playground",           1_000, 11, :pending,  "Logo 9.jpg" ],
  [ "Nimbus Data Storage",          999, 21, :pending,  "Logo 12.jpg" ],
  [ "ByteWise",                   4_999, 23, :pending,  "Logo 11.jpg" ],
  [ "Lumina Energy",              2_999,  8, :overdue,  "Logo 14.jpg" ]
].freeze

BILLS.each do |title, amount_cents, due_day, status, avatar|
  user.recurring_bills.create!(
    title: title,
    amount_cents: amount_cents,
    due_day: due_day,
    status: status,
    avatar: avatar
  )
end

puts "Seeded: #{user.transactions.count} transactions, " \
     "#{user.budgets.count} budgets, #{user.pots.count} pots " \
     "(#{PotTransaction.count} ledger entries), " \
     "#{user.recurring_bills.count} bills for #{user.email}"

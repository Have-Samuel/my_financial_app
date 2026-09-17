module ApplicationHelper
  def money(cents)
    number_to_currency(cents.to_i / 100.0)
  end

  # path: nil renders an inert item until that section ships.
  def nav_items
    [
      { label: "Overview",        icon: "fa-house",     path: root_path },
      { label: "Transactions",    icon: "fa-receipt",   path: transactions_path },
      { label: "Budgets",         icon: "fa-chart-pie", path: nil },
      { label: "Pots",            icon: "fa-jar",       path: nil },
      { label: "Recurring Bills", icon: "fa-repeat",    path: nil }
    ]
  end
end

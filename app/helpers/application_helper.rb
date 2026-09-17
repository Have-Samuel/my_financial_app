module ApplicationHelper
  def money(cents)
    number_to_currency(cents.to_i / 100.0)
  end

  # path: nil renders an inert item until that section ships.
  # Fixed palette matching the reference design; used for budget/pot themes.
  THEME_COLORS = [
    [ "Green",  "#277c78" ],
    [ "Yellow", "#f2cdac" ],
    [ "Cyan",   "#82c9d7" ],
    [ "Navy",   "#626070" ],
    [ "Red",    "#c94736" ],
    [ "Purple", "#826cb0" ],
    [ "Turquoise", "#597c7c" ],
    [ "Brown",  "#93674f" ],
    [ "Blue",   "#3f82b2" ],
    [ "Gray",   "#97a0ac" ]
  ].freeze

  def theme_colors
    THEME_COLORS
  end

  def nav_items
    [
      { label: "Overview",        icon: "fa-house",     path: root_path },
      { label: "Transactions",    icon: "fa-receipt",   path: transactions_path },
      { label: "Budgets",         icon: "fa-chart-pie", path: budgets_path },
      { label: "Pots",            icon: "fa-jar",       path: pots_path },
      { label: "Recurring Bills", icon: "fa-repeat",    path: nil }
    ]
  end
end

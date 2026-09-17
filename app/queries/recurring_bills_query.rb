class RecurringBillsQuery
  SORTS = %w[due_soon a-z z-a highest lowest].freeze

  def initialize(scope, params = {})
    @scope = scope
    @params = params
  end

  def results
    bills = @scope
    bills = bills.search(@params[:q]) if @params[:q].present?

    case sort
    when "a-z"     then bills.order(:title)
    when "z-a"     then bills.order(title: :desc)
    when "highest" then bills.order(amount_cents: :desc)
    when "lowest"  then bills.order(:amount_cents)
    else bills.sort_by(&:days_until_due) # due_day is day-of-month; in-memory sort handles month wraparound
    end
  end

  def sort
    SORTS.include?(@params[:sort]) ? @params[:sort] : "due_soon"
  end
end

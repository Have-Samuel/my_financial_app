class TransactionsQuery
  PER_PAGE = 10

  SORTS = {
    "latest"   => { occurred_on: :desc, created_at: :desc },
    "oldest"   => { occurred_on: :asc },
    "highest"  => { amount_cents: :desc, occurred_on: :desc },
    "lowest"   => { amount_cents: :asc, occurred_on: :desc },
    "a-z"      => { recipient: :asc },
    "z-a"      => { recipient: :desc }
  }.freeze

  def initialize(scope, params = {})
    @scope = scope
    @params = params
  end

  def results
    filtered.order(SORTS.fetch(sort)).offset(page * PER_PAGE).limit(PER_PAGE)
  end

  # Whitelisted sort key — unknown values fall back to latest.
  def sort
    SORTS.key?(@params[:sort]) ? @params[:sort] : "latest"
  end

  def page
    [ @params[:page].to_i, 0 ].max
  end

  def total_count
    @total_count ||= filtered.count
  end

  def total_pages
    (total_count / PER_PAGE.to_f).ceil
  end

  private

  def filtered
    @filtered ||= begin
      scope = @scope
      scope = scope.search(@params[:q]) if @params[:q].present?
      scope = scope.in_category(@params[:category_id]) if @params[:category_id].present?
      scope
    end
  end
end

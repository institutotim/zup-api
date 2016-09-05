class Reports::GetStats
  attr_accessor :categories, :begin_date, :end_date, :namespace_id

  def initialize(category_id, namespace_id, filters = {})
    if category_id.is_a? Array
      @categories = category_id.map do |id|
        Reports::Category.find(id)
      end
    else
      @categories = [Reports::Category.find(category_id)]
    end

    @namespace_id = namespace_id
    @begin_date = filters[:begin_date]
    @end_date = filters[:end_date]
  end

  def fetch
    stats = []

    categories.each do |category|
      stats << fetch_stats_from_category(category)
    end

    stats
  end

  private

  def fetch_stats_from_category(category)
    category_stats = {}
    category_stats.merge!(
      category_id: category.id,
      name: category.title
    )

    subcategories_ids = category.subcategories.pluck(:id) || []
    subcategories_ids << category.id

    # Get all statuses, from the categories
    category_statuses = Reports::StatusCategory.joins(:category)
                                               .where(
                                                 reports_statuses_reports_categories: {
                                                   reports_category_id: subcategories_ids,
                                                   private: false
                                                 }
                                               ).map(&:status)

    # Statuses
    category_statuses = category_statuses.group_by do |s|
      s.title.downcase
    end

    statuses_stats = []
    category_statuses.each do |_title, statuses|
      statuses_stats << fetch_stats_from_statuses(statuses, category)
    end

    category_stats[:statuses] = statuses_stats
    category_stats
  end

  def fetch_stats_from_statuses(statuses, category)
    count = 0

    statuses.each do |status|
      sc = status.for_category(category, namespace_id)
      next unless sc

      reports_items = status.reports_items.where(reports_category_id: category.id)

      if begin_date || end_date
        reports_items = reports_items_filtered_by_date(reports_items, begin_date, end_date)
      end

      count += reports_items.count
    end

    status = statuses.first
    first_sc = status.for_category(category, namespace_id)

    {
      status_id: status.id, # Deprecated
      title: status.title,
      count: count,
      color: first_sc.try(:color)
    }
  end

  def reports_items_filtered_by_date(reports_items, begin_date, end_date)
    if begin_date && end_date
      reports_items.where(created_at: begin_date..end_date)
    elsif begin_date
      reports_items.where('created_at >= ?', begin_date)
    elsif end_date
      reports_items.where('created_at <= ?', end_date)
    end
  end
end

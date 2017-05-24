class CreateSuggestionsToGroupReports
  include Sidekiq::Worker

  def perform
    suggestions = Reports::Item.connection.execute(suggestions_sql)

    suggestions.each do |suggestion|
      Reports::Suggestion.create(suggestion)
    end
  end

  def suggestions_sql
    <<-SQL
      SELECT
        reports.id AS reports_item_id,
        reports.reports_category_id AS reports_category_id,
        reports.address AS address,
        reports.namespace_id,
        ARRAY_AGG(items.id) reports_items_ids

      FROM reports_items reports
      INNER JOIN reports_statuses_reports_categories sc
        ON sc.reports_category_id = reports.reports_category_id
      AND sc.reports_status_id = reports.reports_status_id
      AND sc.namespace_id = reports.namespace_id
      AND sc.final = FALSE,

      (
        SELECT rp.*
        FROM reports_items rp
        INNER JOIN reports_statuses_reports_categories sc
          ON sc.reports_category_id = rp.reports_category_id
          AND sc.reports_status_id = rp.reports_status_id
          AND sc.namespace_id = rp.namespace_id
          AND sc.final = FALSE
        WHERE rp.group_key IS NULL
          AND rp.district IS NOT NULL
          AND rp.postal_code IS NOT NULL
      ) items

      WHERE similarity(UNACCENT(items.address), UNACCENT(reports.address)) > 0.5
      AND (
        similarity(UNACCENT(items.district), UNACCENT(reports.district)) > 0.5 OR
        similarity(items.postal_code, reports.postal_code) > 0.75
      )
      AND reports.number = items.number
      AND reports.namespace_id = items.namespace_id
      AND items.reports_category_id = reports.reports_category_id
      AND COALESCE(reports.number, '') != ''
      AND UPPER(COALESCE(reports.number, '')) != 'S/N'
      AND reports.group_key IS NULL
      AND reports.district IS NOT NULL
      AND reports.postal_code IS NOT NULL

      GROUP BY reports.id, reports.reports_category_id, reports.address, reports.namespace_id

      HAVING ARRAY_LENGTH(ARRAY_AGG(items.id), 1) > 1
    SQL
  end
end

class SetReportsOverdue
  include Sidekiq::Worker

  sidekiq_options queue: :high

  # Send push notification for mobile clients
  def perform
    sc_table = Reports::StatusCategory.table_name
    reports_item_table = Reports::Item.table_name
    reports_category_table = Reports::Category.table_name
    history_table = Reports::ItemStatusHistory.table_name
    settings_table = Reports::CategorySetting.table_name

    overdue_reports = <<-SQL
      SELECT DISTINCT #{reports_item_table}.id
      FROM #{reports_item_table}

      INNER JOIN "#{reports_category_table}"
      ON "#{reports_category_table}"."id" = "#{reports_item_table}"."reports_category_id"

      INNER JOIN "#{sc_table}"
      ON "#{sc_table}"."reports_category_id" = "#{reports_item_table}"."reports_category_id"
      AND "#{sc_table}"."reports_status_id" = "#{reports_item_table}"."reports_status_id"
      AND "#{sc_table}"."final" = FALSE

      INNER JOIN "#{settings_table}"
      ON "#{settings_table}"."reports_category_id" = "#{reports_item_table}"."reports_category_id"
      AND "#{settings_table}"."namespace_id" = "#{reports_item_table}"."namespace_id"

      INNER JOIN "#{history_table}"
      ON "#{history_table}"."reports_item_id" = "#{reports_item_table}"."id"

      WHERE "#{settings_table}".resolution_time IS NOT NULL
      AND "#{settings_table}".resolution_time_enabled = TRUE
      AND "#{reports_item_table}"."overdue" = FALSE
      AND ("#{history_table}"."created_at" + (INTERVAL '1 second' * #{settings_table}.resolution_time)) < NOW()
    SQL

    items = Reports::Item.where("id IN (#{overdue_reports})")
    items.find_in_batches do |group|
      group.each do |item|
        unless item.overdue?
          item.update(overdue: true, overdue_at: Time.now)

          Reports::CreateHistoryEntry.new(item)
            .create('overdue', 'Relato entrou em atraso, quando estava no status:',
                    new: item.status.entity(only: [:id, :name])
            )
        end
      end
    end
  end
end

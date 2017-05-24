module Reports
  class GroupItems
    attr_reader :key, :user, :reports

    def initialize(user, reports)
      @user = user
      @reports = Array(reports)
      @key = SecureRandom.hex
    end

    def group!
      validate_reports

      reports.each do |report|
        if report.grouped_reports.any?
          report.grouped_reports.update_all(group_key: key)
        else
          report.update!(group_key: key)
        end

        create_group_history(report)
      end
    end

    def ungroup!
      reports.each do |report|
        if report.grouped_reports.count == 2
          report.grouped_reports.update_all(group_key: nil)
        else
          report.update!(group_key: nil)
        end

        create_ungroup_history(report)
      end
    end

    private

    def validate_reports
      validate_minimum_of_reports
      validate_categories
      validate_statuses
    end

    def validate_minimum_of_reports
      fail "Can't group a single report" if reports.size <= 1
    end

    def validate_categories
      category_ids = reports.map { |r| r.reports_category_id }.uniq

      if category_ids.size > 1
        fail "Can't group reports from different categories"
      end
    end

    def validate_statuses
      status_ids = reports.map { |r| r.reports_status_id }.uniq

      if Reports::Status.where(id: status_ids).final.any?
        fail "Can't grouped reports with final status"
      end
    end

    def create_group_history(report)
      items     = reports.reject { |r| r.id == report.id }
      protocols = items.map { |i| "##{i.protocol}" }

      history_entry(
        report,
        'grouped',
        "O relato esta agrupado com os seguintes relatos: #{ protocols.join(", ")}",
        new: Reports::Item::Entity.represent(items, only: [:id, :title, :protocol])
      )
    end

    def create_ungroup_history(report)
      history_entry(
        report,
        'ungrouped',
        'O relato esta não esta mais agrupado a nenhum outro relato'
      )
    end

    def history_entry(report, kind, message, options = {})
      Reports::CreateHistoryEntry.new(report, user).create(
        kind, message, options
      )
    end
  end
end

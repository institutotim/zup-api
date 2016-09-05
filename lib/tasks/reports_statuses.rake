namespace :reports_statuses do
  task fix_additional_info: :environment do
    Reports::Status.all.each do |status|
      status.status_categories.update_all(
        private: status.private,
        active: status.active,
        initial: status.initial,
        final: status.final
      )
    end
  end
end

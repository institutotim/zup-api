class AddColorToReportsStatusesReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_statuses_reports_categories, :color, :string

    # Normalize status categories
    Reports::StatusCategory.all.each do |sc|
      if sc.status
        sc.update(color: sc.status.color)
      else
        sc.destroy
      end
    end
  end
end

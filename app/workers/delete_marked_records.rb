class DeleteMarkedRecords
  include Sidekiq::Worker
  DAYS_TO_DELETE = 30.days

  def perform
    delete_reports_categories
    delete_inventory_categories
  end

  private

  def delete_reports_categories
    delete_for Reports::Category
  end

  def delete_inventory_categories
    delete_for Inventory::Category
  end

  def delete_for(scope)
    scope.where('deleted_at <= ?', DAYS_TO_DELETE.ago).find_each do |record|
      record.destroy
    end
  end
end

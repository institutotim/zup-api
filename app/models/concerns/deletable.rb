module Deletable
  extend ActiveSupport::Concern

  def delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def days_for_deletion
    if deleted_at
      days = DeleteMarkedRecords::DAYS_TO_DELETE
      (((deleted_at + days) - Time.current) / 86400).round
    end
  end
end

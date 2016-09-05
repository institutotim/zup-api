# enconding: utf-8
class SetDefaultNamespace < ActiveRecord::Migration
  class Namespace < ActiveRecord::Base; end

  def change
    default_namespace = Namespace.find_or_create_by(name: 'Global', default: true)

    tables_to_migrate = %w(
      groups users reports_statuses_reports_categories reports_categories_perimeters
      chat_rooms reports_notification_types reports_perimeters reports_items
      inventory_items cases
    )

    tables_to_migrate.each do |table|
      execute "UPDATE #{table} SET namespace_id=#{default_namespace.id} WHERE namespace_id IS NULL"
    end

    CreateStatusesForNamespace.new(default_namespace).create!
  end
end

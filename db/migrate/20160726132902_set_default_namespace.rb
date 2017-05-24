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

    Reports::Category.find_each do |category|
      category.settings.create_with(
        resolution_time_enabled: category.resolution_time_enabled,
        resolution_time: category.resolution_time,
        perimeters: category.perimeters,
        private_resolution_time: category.private_resolution_time,
        user_response_time: category.user_response_time,
        notifications: category.notifications,
        allows_arbitrary_position: category.allows_arbitrary_position,
        confidential: category.confidential,
        flow_id: category.flow_id,
        priority: category.priority || 0,
        solver_groups_ids: category.solver_groups_ids,
        comment_required_when_forwarding: category.comment_required_when_forwarding,
        comment_required_when_updating_status: category.comment_required_when_updating_status,
        ordered_notifications: category.ordered_notifications,
        default_solver_group_id: category.default_solver_group_id
      ).find_or_create_by(namespace_id: default_namespace.id)
    end
  end
end

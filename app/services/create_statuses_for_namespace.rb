class CreateStatusesForNamespace
  attr_reader :namespace, :default_namespace

  def initialize(namespace)
    @namespace = namespace
    @default_namespace = Namespace.default.first
  end

  def create!
    categories.find_each do |category|
      category.settings.find_or_create_by!(namespace_id: namespace.id)

      category_statuses = category.status_categories
                                  .where(namespace_id: default_namespace.id)

      category_statuses.each do |category_status|
        create_statuses(category, category_status)
      end
    end
  end

  private

  def categories
    @categories ||= Reports::Category.where(namespace_id: nil)
                                     .includes(:statuses)
  end

  def create_statuses(category, status)
    return if category.status_categories.exists?(
      reports_status_id: status.reports_status_id, namespace_id: namespace.id
    )

    category.status_categories.create!(
      status: status.status,
      namespace: namespace,
      initial: status.initial,
      final: status.final,
      active: status.active,
      private: status.private,
      color: status.color || '#cccccc'
    )
  end
end

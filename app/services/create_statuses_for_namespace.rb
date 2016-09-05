class CreateStatusesForNamespace
  attr_reader :namespace

  def initialize(namespace)
    @namespace = namespace
  end

  def create!
    categories = Reports::Category.includes(:statuses)

    categories.find_each do |category|
      category.settings.find_or_create_by!(namespace_id: namespace.id)

      category.statuses.each do |status|
        next if category.status_categories.exists?(
          reports_status_id: status.id, namespace_id: namespace.id
        )

        category.status_categories.create!(
          status: status,
          namespace: namespace,
          initial: status.initial,
          final: status.final,
          active: status.active,
          private: status.private,
          color: status.color || '#cccccc'
        )
      end
    end
  end
end

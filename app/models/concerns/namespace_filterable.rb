module NamespaceFilterable
  extend ActiveSupport::Concern

  included do
    scope :filter_all_namespaces, ->(id) do
      where(
        "#{table_name}.namespace_id IS NULL OR #{table_name}.namespace_id = :id OR :id = ANY(#{table_name}.namespaces_ids)",
        id: id
      )
    end

    scope :filter_namespace, ->(id) do
      where(namespace_id: [nil, id])
    end

    scope :filter_namespaces, ->(id) do
      where("? = ANY(#{table_name}.namespaces_ids)", id)
    end

    default_scope do
      current_namespace = Thread.current[:current_namespace]

      if current_namespace
        if column_names.include?('namespace_id') && column_names.include?('namespaces_ids')
          filter_all_namespaces(current_namespace)
        elsif column_names.include?('namespace_id')
          filter_namespace(current_namespace)
        elsif column_names.include?('namespaces_ids')
          filter_namespaces(current_namespace)
        end
      end
    end
  end
end

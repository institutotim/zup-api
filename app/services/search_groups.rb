class SearchGroups
  attr_reader :signed_user, :query, :group_name, :user_name, :global_namespaces,
    :namespace_id

  def initialize(user, options = {})
    @signed_user = user

    @ignore_namespaces = options[:ignore_namespaces]
    @query      = options[:query]
    @user_name  = options[:user_name]
    @group_name = options[:name]
    @groups_ids = options[:groups_ids]
    @global_namespaces = options.fetch(:global_namespaces) { false }
    @namespace_id = options[:namespace_id]
  end

  def fetch
    @scope = Group.eager_load(:users, :permission, :namespace)

    unless @ignore_namespaces
      namespaces =
          if global_namespaces
            Namespace.default.pluck(:id).push(namespace_id)
          else
            namespace_id
          end
    end

    @scope = @scope.where(namespace_id: namespaces) if namespaces

    build_permissions_filter
    build_query_filter
    build_name_filter

    @scope
  end

  protected

  def build_permissions_filter
    permissions = UserAbility.for_user(signed_user)

    # Find a way to remove these ugly permissions checking:
    unless permissions.can?(:manage, Group) ||
      signed_user.permissions.inventories_categories_edit.any? ||
      signed_user.permissions.reports_categories_edit.any? ||
      signed_user.permissions.reports_items_forward.any? ||
      signed_user.permissions.reports_items_edit.any? ||
      signed_user.permissions.inventories_full_access ||
      signed_user.permissions.can_execute_step.any? ||
      signed_user.permissions.flow_can_execute_all_steps.any? ||
      signed_user.permissions.reports_full_access

      @scope = @scope.where(groups: { id: permissions.groups_visible })
    end
  end

  def build_query_filter
    return unless query

    @scope = @scope.search_by_name(query)
  end

  def build_name_filter
    if group_name
      @scope = @scope.search_by_name(group_name)
    end

    if user_name
      @scope = @scope.search_by_user_name(user_name)
    end
  end
end

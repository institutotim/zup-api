class ListUsers
  AVAILABLE_SORT_FIELDS = ['name', 'username', 'email', 'phone', 'created_at', 'updated_at']

  attr_reader :order, :sort, :name, :email, :document,
              :groups, :scope, :search_params,
              :signed_user, :permissions, :query, :global_namespaces,
              :namespace_id,  :disabled, :filter, :only_service

  def initialize(user, opts = {})
    @signed_user = user
    @name = opts[:name]
    @email = opts[:email]
    @document = opts[:user_document]
    @groups = Array(opts[:groups])
    @query = opts[:query]
    @order = opts[:order]
    @sort = opts[:sort]
    @filter = opts[:filter] # if should be a search or a filter
    @global_namespaces = opts.fetch(:global_namespaces) { false }
    @namespace_id = opts[:namespace_id]
    @disabled = opts[:disabled]
    @only_service = opts[:service]

    @search_params = {}
    @permissions = UserAbility.for_user(signed_user)
    @scope = User.distinct

    unless opts[:disabled]
      @scope = @scope.enabled
    end
  end

  def fetch
    build_scope
    build_permissions_filter
    build_kind_filter
    build_name_search
    build_email_search
    build_document_search
    build_group_search
    build_query_search
    build_ordering_search

    scope
  end

  private

  def build_kind_filter
    if only_service
      @scope = scope.service
    else
      @scope = scope.user
    end
  end

  def build_scope
    @scope = User.distinct.includes(:namespace)

    namespaces =
      if global_namespaces
        Namespace.default.pluck(:id).push(namespace_id)
      else
        namespace_id
      end

    @scope = @scope.where(namespace_id: namespaces) if namespaces

    unless disabled
      @scope = @scope.enabled
    end
  end

  def build_permissions_filter
    return if can_see_all_users?
    @scope = scope.joins(:groups).where('groups.id IN (?)', permissions.groups_visible)
  end

  def build_ordering_search
    if sort &&
      sort.in?(AVAILABLE_SORT_FIELDS) &&
        %w(desc asc).include?(order.downcase)

      @scope = scope.reorder("users.#{sort} #{order}")
    else
      @scope = scope.reorder('users.id ASC')
    end
  end

  def build_name_search
    return unless name
    @scope = scope.search_by_name(name)
  end

  def build_email_search
    return unless email

    if filter
      @scope = scope.where(email: email)
    else
      @scope = scope.search_by_email(email)
    end
  end

  def build_document_search
    return unless document
    @scope = scope.search_by_document(document)
  end

  def build_group_search
    return unless groups.any?

    groups_ids = groups.map(&:id)
    @scope = scope.joins(:groups).where('groups.id IN (?)', groups_ids)
  end

  def build_query_search
    return unless query
    @scope = scope.search_by_query(query)
  end

  def can_see_all_users?
    if only_service
      permissions.can?(:manage_services, User)
    else
      permissions.can?(:manage, User) ||
      permissions.can?(:manage, Group) ||
      permissions.can?(:manage, Case) ||
      signed_user.permissions.group_edit.any? ||
      signed_user.permissions.reports_categories_edit.any? ||
      signed_user.permissions.reports_items_edit.any? ||
      signed_user.permissions.reports_full_access ||
      signed_user.permissions.cases_with_reports_view.any?
    end
  end
end

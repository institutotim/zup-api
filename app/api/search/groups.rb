module Search
  module Groups
    class API < Base::API
      desc 'Search for groups'
      paginate per_page: 25
      params do
        optional :name, type: String, desc: 'The name of the group to search for'
        optional :ignore_namespaces, type: Boolean, desc: 'Ignore namespace system'
        optional :global_namespaces, type: Boolean,
          desc: 'Return groups of current namespace and global namespace'
        optional :use_user_namespace, type: Boolean,
          desc: 'Use user namespace instead current namespace to filter groups'
      end
      get :groups do
        authenticate!

        search_params = safe_params.permit(:global_namespaces)
        search_params[:query] = safe_params[:name]
        search_params[:ignore_namespaces] = safe_params[:ignore_namespaces]

        search_params[:namespace_id] =
          if params[:use_user_namespace]
            current_user.namespace_id
          else
            app_namespace_id
          end

        groups = SearchGroups.new(current_user, search_params).fetch

        {
          groups: Group::Entity.represent(paginate(groups), only: return_fields)
        }
      end
    end
  end
end

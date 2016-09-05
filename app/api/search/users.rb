module Search::Users
  class API < Base::API
    desc 'Search for users'
    paginate per_page: 25
    params do
      optional :name, type: String, desc: 'The name of the user to search for'
      optional :email, type: String, desc: 'The email of the user to search for'
      optional :sort, type: String, desc: 'The field to sort the users. Values: `name`, `username`, `phone`, `email`, `created_at`, `updated_at`'
      optional :order, type: String, desc: 'The order, can be `desc` or `asc`'
      optional :disabled, type: Boolean, desc: 'Return disabled users'
      optional :user_document, type: String, desc: 'User document, only numbers'
      optional :query, type: String, desc: 'Query to search users by name, document or email'
      optional :global_namespaces, type: Boolean,
        desc: 'Return users of current namespace and global namespace'
      optional :ignore_namespaces, type: Boolean, desc: 'Ignore namespace system'
    end
    get :users do
      authenticate!

      if safe_params[:groups]
        groups = Group.find(safe_params[:groups].split(','))
      end

      search_params = safe_params.permit(:name, :email, :user_document, :sort, :order,
        :disabled, :query, :global_namespaces)

      search_params[:groups] = groups

      search_params[:namespace_id] = app_namespace_id unless safe_params[:ignore_namespaces]

      users = ListUsers.new(current_user, search_params).fetch
      users = paginate(users.paginate(page: params[:page]))

      {
        users: User::Entity.represent(users, only: return_fields, display_type: 'full', show_groups: true)
      }
    end

    desc 'Search for users on a group'
    paginate per_page: 25
    params do
      requires :group_id, type: Integer
      optional :name, type: String, desc: 'The name of the user to search for'
      optional :email, type: String, desc: 'The email of the user to search for'
      optional :sort, type: String,
        desc: 'The field to sort the users. Values: `name`, `username`, `phone`, `email`, `created_at`, `updated_at`'
      optional :order, type: String,
        desc: 'The order, can be `desc` or `asc`'
      optional :user_document, type: String,
               desc: 'User document, only numbers'
      optional :disabled, type: Boolean, desc: 'Return disabled users'
      optional :query, type: String, desc: 'Query to search users by name, document or email'
      optional :global_namespaces, type: Boolean,
        desc: 'Return users of current namespace and global namespace'
    end
    get 'groups/:group_id/users' do
      authenticate!

      group = Group.find(safe_params[:group_id])

      search_params = safe_params.permit(:name, :email, :user_document, :sort, :order,
        :disabled, :query, :global_namespaces)

      search_params[:groups] = [group]
      search_params[:namespace_id] = app_namespace_id

      users = ListUsers.new(current_user, search_params).fetch
      users = paginate(users.paginate(page: params[:page]))

      {
        users: User::Entity.represent(users, only: return_fields, display_type: 'full', show_groups: true)
      }
    end
  end
end

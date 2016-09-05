module Namespaces
  class API < Base::API
    helpers do
      def load_namespace
        Namespace.find(params[:id])
      end

      def namespace_params
        safe_params.permit(:name)
      end
    end

    namespace :namespaces do
      desc 'List all namespaces'
      get do
        authenticate!

        namespaces = Namespace.all

        unless user_permissions.can?(:manage, Namespace)
          namespaces = namespaces.search_by_id(user_permissions.namespaces_visible)
        end

        namespaces = paginate(namespaces)

        {
          namespaces: Namespace::Entity.represent(namespaces)
        }
      end

      desc 'Create a new namespace'
      params do
        requires :name, type: String, desc: 'Name of the namespace'
      end
      post do
        authenticate!

        validate_permission!(:create, Namespace)

        service = CreateNamespace.new
        service.create!(namespace_params)

        {
          namespace: Namespace::Entity.represent(service.namespace)
        }
      end

      desc 'Show namespace info'
      get ':id' do
        authenticate!

        namespace = load_namespace
        validate_permission!(:show, namespace)

        {
          namespace: Namespace::Entity.represent(namespace)
        }
      end

      desc 'Update the namespace'
      params do
        requires :name, type: String, desc: 'Name of the namespace'
      end
      put ':id' do
        authenticate!

        namespace = load_namespace
        validate_permission!(:update, namespace)
        namespace.update!(namespace_params)

        {
          namespace: Namespace::Entity.represent(namespace)
        }
      end

      desc 'Delete the namespace'
      delete ':id' do
        authenticate!

        namespace = load_namespace
        validate_permission!(:delete, namespace)

        fail 'You cannot delete a default namespace' if namespace.default?

        if namespace.destroy
          MigrateNamespaces.perform_async(namespace.id)

          status 204
        else
          status 422
        end
      end
    end
  end
end

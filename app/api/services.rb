module Services
  class API < Base::API
    helpers do
      def load_service
        User.service.find(params[:id])
      end
    end

    namespace :services do
      desc 'List all services'
      params do
        optional :name, type: String, desc: 'Filter services by name'
        optional :disabled, type: Boolean, desc: 'Return disabled services'
        optional :sort, type: String, desc: 'The field to sort the users. Values: `name`, `email`, `created_at`, `updated_at`'
        optional :order, type: String, desc: 'The order, can be `desc` or `asc`'
      end
      get do
        authenticate!

        validate_permission!(:manage_services, User)

        search_params = safe_params.permit(:name, :disabled, :sort, :order)
        search_params[:service] = true

        services = ListUsers.new(current_user, search_params).fetch
        services = services.includes(:token)
        services = paginate(services.paginate(page: params[:page]))

        {
          services: User::Entity.represent(
            services,
            only: return_fields,
            collection: true
          )
        }
      end

      desc 'Create a new service'
      params do
        requires :name, type: String, desc: 'Name of service'
        optional :email, type: String, desc: 'Email of service responsible'
      end
      post do
        authenticate!

        validate_permission!(:manage_services, User)

        service_params = safe_params.permit(:name, :email)
        service_params[:kind] = 'service'

        service = User.create!(service_params)

        {
          service: User::Entity.represent(service, only: return_fields)
        }
      end

      desc 'Update a service'
      params do
        optional :name, type: String, desc: 'Name of service'
        optional :email, type: String, desc: 'Email of service responsible'
        optional :disabled, type: Boolean, desc: 'Disable the service'
      end
      put ':id' do
        authenticate!

        validate_permission!(:manage_services, User)

        service = load_service

        service_params = safe_params.permit(:name, :email, :disabled)
        service.update(service_params)

        {
          service: User::Entity.represent(service, only: return_fields)
        }
      end

      desc 'Show service info'
      get ':id' do
        authenticate!

        validate_permission!(:manage_services, User)

        service = load_service

        {
          service: User::Entity.represent(service, only: return_fields)
        }
      end

      desc 'Disable a service'
      delete ':id' do
        authenticate!

        validate_permission!(:manage_services, User)

        service = load_service
        service.disable!

        {
          message: 'Serviço deletado com sucesso'
        }
      end

      desc 'Enable a service'
      put ':id/enable' do
        authenticate!

        validate_permission!(:manage_services, User)

        service = load_service
        service.enable!

        {
          message: 'Serviço habilitado com sucesso'
        }
      end
    end
  end
end

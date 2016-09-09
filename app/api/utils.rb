module Utils
  class API < Base::API
    desc 'Validates if lat and lon is allowed for the city'
    params do
      requires :latitude, type: Float
      requires :longitude, type: Float
    end
    get '/utils/city-boundary/validate' do
      latitude, longitude = params[:latitude], params[:longitude]

      if CityShape.validation_enabled?
        { inside_boundaries: CityShape.contains?(latitude, longitude) }
      else
        { message: 'Validação para limite municipal não está ativo' }
      end
    end

    desc 'Return all available objects for permissions'
    get '/utils/available_objects' do
      authenticate!

      ability = UserAbility.for_user(current_user)

      unless ability.can?(:manage, Group) || current_user.permissions.group_edit.any?
        error!(I18n.t(:permission_denied, action: :manage, table_name: :groups), 403)
      end

      default_namespace = Namespace.find_by_default(true)

      groups = Group.includes(:permission).all.unscoped
      flows = Flow.all.unscoped
      flow_steps = Step.all.unscoped
      inventory_categories = Inventory::Category.all.unscoped
      reports_categories = Reports::Category.main.includes(:statuses, :subcategories).all.unscoped
      business_reports = BusinessReport.all.unscoped
      chat_rooms = ChatRoom.all.unscoped
      namespaces = Namespace.all.unscoped

      {
        groups: Group::Entity.represent(groups, only: [:id, :name, :namespace]),
        flows: Flow::Entity.represent(flows, only: [:id, :title]),
        flow_steps: Step::Entity.represent(flow_steps, only: [:id, :title]),
        inventory_categories: Inventory::Category::Entity.represent(inventory_categories, only: [:id, :title, :namespace]),
        reports_categories: Reports::Category::Entity.represent(reports_categories, only: [:id, :title, :namespace, subcategories: [:id, :title, :namespace]], display_type: :full, default_namespace: default_namespace),
        business_reports: BusinessReport::Entity.represent(business_reports, only: [:id, :title, :namespace]),
        chat_rooms: ChatRoom::Entity.represent(chat_rooms, only: [:id, :title, :namespace]),
        namespaces: namespaces
      }
    end
  end
end

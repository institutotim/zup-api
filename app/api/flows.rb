module Flows
  class API < Base::API
    resources :flows do
      desc 'List of all flows'
      params do
        optional :query,        type: String, desc: 'Query of search'
        optional :initial,      type: Boolean, desc: 'Filter by Initial Flow'
        optional :sort,         type: String,  desc: 'The field to sort the cases. Valid fields: id, title, updated_at, created_at'
        optional :order,        type: String,  desc: 'The order, can be `desc` or `asc`'
        optional :display_type, type: String,  desc: 'Display type for Flow'
        optional :can_create_case, type: Boolean, desc: 'Only return flows that can create a case'
      end
      paginate per_page: 25
      get do
        authenticate!
        validate_permission!(:show, Flow)

        columns_permitted = ['id', 'title', 'updated_at', 'created_at']
        order = safe_params[:order].to_sym if ['asc', 'desc'].include? safe_params[:order]
        sort  = safe_params[:sort] if columns_permitted.include? safe_params[:sort]

        order ||= :asc
        sort  ||= 'id'

        flows = Flow.active.includes(:created_by, :updated_by, :resolution_states, :steps)
                           .where(safe_params.permit(:initial))
                           .order(sort => order)

        if safe_params[:query].present?
          flows = flows.search(safe_params[:query])
        end

        flows = paginate(flows)

        if params[:can_create_case]
          flows = flows.select { |f| f.versions.any? }.compact
        end

        {
          flows: Flow::Entity.represent(
            flows,
            only: return_fields,
            display_type: safe_params[:display_type]
          )
        }
      end

      desc 'Create a flow'
      params do
        requires :title,       type: String,  desc: 'Title of flow'
        optional :description, type: String,  desc: 'Description of flow'
        optional :initial,     type: Boolean, desc: 'If flow is initial'
        optional :resolution_states, type: Array,   desc: 'Set of resolution states to be persisted on this flow' do
          requires :title, type: String
          optional :default, type: Boolean
          optional :active, type: Boolean
          optional :id, type: Integer
        end
      end
      post do
        authenticate!
        validate_permission!(:create, Flow)

        flow_params = safe_params.permit(:title, :description, :initial).merge(created_by: current_user)
        flow = Flow.create!(flow_params)

        flow_params.merge!(safe_params.permit(resolution_states: [:id, :title, :default]))
        if flow_params[:resolution_states]
          validate_permission!(:create, ResolutionState)
          flow.update_resolution_states(flow_params[:resolution_states].map { |rs| rs.merge!(user: current_user) })
        end

        { message: I18n.t(:flow_created), flow: Flow::Entity.represent(flow, only: return_fields, display_type: 'full') }
      end

      resource ':id' do
        desc 'Show a flow'
        params do
          optional :display_type, type: String,  desc: 'Display type for Flow'
          optional :version,      type: Integer, desc: 'Version ID (last version by default)'
          optional :draft,        type: Boolean, desc: 'Draft or Live version (false by default)'
        end
        get do
          authenticate!
          validate_permission!(:view, Flow)

          flow = Flow.find(safe_params[:id]).the_version(safe_params[:draft], safe_params[:version])
          { flow: Flow::Entity.represent(flow, only: return_fields, display_type: safe_params[:display_type]) }
        end

        desc 'Delete a flow'
        delete do
          authenticate!
          validate_permission!(:delete, Flow)

          flow = Flow.find(safe_params[:id])
          flow.user = current_user
          flow.inactive!
          { message: I18n.t(:flow_deleted) }
        end

        desc 'Update a flow'
        params do
          optional :title,             type: String,  desc: 'Title of flow'
          optional :description,       type: String,  desc: 'Description of flow'
          optional :initial,           type: Boolean, desc: 'If flow is initial'
          optional :resolution_states, type: Array,   desc: 'Set of resolution states to be persisted on this flow' do
            requires :title, type: String
            optional :default, type: Boolean
            optional :active, type: Boolean
            optional :id, type: Integer
          end
        end
        put do
          authenticate!
          validate_permission!(:update, Flow)
          flow_params = safe_params.permit(:title, :description, :initial)
          flow_params.merge!(updated_by: current_user)
          flow = Flow.find(safe_params[:id])
          extra_params = safe_params.permit(resolution_states: [:id, :title, :default, :active])

          if extra_params[:resolution_states]
            validate_permission!(:update, ResolutionState)
            flow.update_resolution_states(extra_params[:resolution_states].map { |rs| rs.merge!(user: current_user) })
          end

          flow.update!(flow_params)
          { message: I18n.t(:flow_updated) }
        end

        desc 'Show ancestors of the flow'
        params { optional :display_type, type: String, desc: 'Display type for Flow' }
        get 'ancestors' do
          authenticate!
          validate_permission!(:view, Flow)

          ancestors = Flow.find(safe_params[:id]).ancestors
          { flows: (safe_params[:display_type] == 'full') ? Flow::Entity.represent(ancestors, only: return_fields) : ancestors.map(&:id) }
        end

        desc 'Change the useful version of Flow'
        params { requires :new_version, type: Integer, desc: 'New Version ID to Default' }
        put 'version' do
          authenticate!
          validate_permission!(:manage, Flow)

          flow = Flow.find(safe_params[:id])
          error!(I18n.t(:version_isnt_valid), 400) if flow.versions.size.zero? || !flow.versions.pluck(:id).include?(safe_params[:new_version].to_i)
          flow.update!(current_version: safe_params[:new_version].to_i)

          { message: I18n.t(:flow_version_updated, version: safe_params[:new_version]) }
        end

        desc 'Set Permissions to Flow of Case'
        params do
          requires :group_ids,       type: Array,  desc: 'Array of Group IDs'
          requires :permission_type, type: String, desc: 'Permission type to change (flow_can_execute_all_steps, flow_can_view_all_steps, flow_can_delete_own_cases, flow_can_delete_all_cases)'
        end
        put 'permissions' do
          authenticate!
          validate_permission!(:manage, Flow)
          permission_type  = safe_params[:permission_type]
          permission_types = %w{flow_can_execute_all_steps flow_can_view_all_steps flow_can_delete_own_cases flow_can_delete_all_cases}
          error!(I18n.t(:permission_type_not_included), 400) unless permission_types.include? permission_type

          safe_params[:group_ids].each do |group_id|
            group       = Group.find(group_id)
            permissions = group.permission.send(permission_type)
            group.permission.send("#{permission_type}=", permissions + [safe_params[:id].to_i])
            group.save!
          end

          { message: I18n.t(:permissions_updated) }
        end

        desc 'Unset Permissions to Flow of Case'
        params do
          requires :group_ids,       type: Array,  desc: 'Array of Group IDs'
          requires :permission_type, type: String, desc: 'Permission type to change (flow_can_execute_all_steps, flow_can_view_all_steps, flow_can_delete_own_cases, flow_can_delete_all_cases)'
        end
        delete 'permissions' do
          authenticate!
          validate_permission!(:manage, Flow)
          permission_type  = safe_params[:permission_type]
          permission_types = %w{flow_can_execute_all_steps flow_can_view_all_steps flow_can_delete_own_cases flow_can_delete_all_cases}
          error!(I18n.t(:permission_type_not_included), 400) unless permission_types.include? permission_type

          safe_params[:group_ids].each do |group_id|
            group       = Group.find(group_id)
            permissions = group.permission.send(permission_type)
            group.permission.send("#{permission_type}=", permissions - [safe_params[:id].to_i])
            group.save!
          end

          { message: I18n.t(:permissions_updated) }
        end

        desc 'Publish the flow'
        post 'publish' do
          authenticate!
          validate_permission!(:manage, Flow)

          Flow.find(safe_params[:id]).publish(current_user)

          { message: I18n.t(:flow_published) }
        end

        desc 'List all inventory_item fields for the flow'
        params do
          optional :inventory_field_contender, type: Boolean, desc: 'Fields with inventory item type'
        end
        get 'fields' do
          authenticate!
          validate_permission!(:view, Flow)

          flow = Flow.find(safe_params[:id])

          fields = flow.fields

          if params[:inventory_field_contender]
            fields = flow.fields.where(field_type: 'inventory_item')
                                .where('cardinality(category_inventory_id) = 1')
          end

          { fields: Field::Entity.represent(fields, only: return_fields, user: current_user) }
        end
      end

      mount Flows::Steps::API
    end
  end
end

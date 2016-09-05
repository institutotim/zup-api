module Flows::Steps
  class API < Base::API
    resources ':flow_id/steps' do
      desc 'List of Steps'
      params { optional :display_type, type: String, desc: 'Display type for Step' }
      get do
        authenticate!
        validate_permission!(:view, Step)
        { steps: Step::Entity.represent(Flow.find(safe_params[:flow_id]).steps, only: return_fields, display_type: safe_params[:display_type]) }
      end

      desc 'Update order of Steps'
      params { requires :ids, type: Array, desc: 'Array with steps ids in order' }
      put do
        authenticate!
        validate_permission!(:update, Step)

        steps = Flow.find(safe_params[:flow_id]).my_steps
        unless steps.map(&:id).sort == safe_params[:ids].sort
          status 400
          break { error: 'As etapas enviadas para ordenação não correspondem as existentes no fluxo.' }
        end
        Step.update_order!(safe_params[:ids])
        { message: I18n.t(:steps_order_updated) }
      end

      desc 'Create a Step'
      params do
        requires :title,                type: String,  desc: 'Title of resolution state'
        optional :conduction_mode_open, type: Boolean, desc: 'Condution mode is Open, true for "open" or false for "selective" (default is true)'
        optional :step_type,            type: String,  desc: 'Type of step (form or flow)'
        optional :child_flow_id,        type: Integer, desc: 'Child Flow id'
        optional :child_flow_version,   type: Integer, desc: 'Child Flow Version'
      end
      post do
        authenticate!
        validate_permission!(:create, Step)

        parameters = safe_params.permit(:title, :conduction_mode_open, :step_type, :child_flow_id, :child_flow_version).merge(user: current_user)
        if parameters[:child_flow_version].blank? && parameters[:child_flow_id].present?
          parameters[:child_flow_version] = Flow.find(parameters[:child_flow_id]).the_version.version
        end
        step = Flow.find(safe_params[:flow_id]).steps.create!(parameters)
        { message: I18n.t(:step_created), step: Step::Entity.represent(step, only: return_fields, display_type: 'full') }
      end

      desc 'Update a Step'
      params do
        optional :title,                type: String,  desc: 'Title of resolution state'
        optional :conduction_mode_open, type: Boolean, desc: 'Condution mode is Open, true for "open" or false for "selective" (default is true)'
        optional :step_type,            type: String,  desc: 'Type of step (form or flow)'
        optional :child_flow_id,        type: Integer, desc: 'Child Flow id'
        optional :child_flow_version,   type: Integer, desc: 'Child Flow Version'
      end
      put ':id' do
        authenticate!
        validate_permission!(:update, Step)

        parameters = safe_params.permit(:title, :conduction_mode_open, :step_type, :child_flow_id, :child_flow_version).merge(user: current_user)
        step       = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id])
        if parameters[:child_flow_version].blank? && parameters[:child_flow_id].present?
          parameters[:child_flow_version] = Flow.find(parameters[:child_flow_id]).the_version.version
        end
        { message: I18n.t(:step_updated) } if step.update!(parameters)
      end

      desc 'Show a Step'
      params { optional :display_type, type: String, desc: 'Display type for Step' }
      get ':id' do
        authenticate!
        validate_permission!(:view, Step)

        step = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id])
        { step: Step::Entity.represent(step, only: return_fields, display_type: safe_params[:display_type]) }
      end

      desc 'Delete a Step'
      delete ':id' do
        authenticate!
        validate_permission!(:delete, Step)

        step = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id])
        step.user = current_user
        step.inactive!
        { message: I18n.t(:step_deleted) }
      end

      desc 'Set Permissions to Step of Case'
      params do
        optional :group_ids,       type: Array,  desc: 'Array of Group IDs'
        requires :permission_type, type: String, desc: 'Permission type to change (can_execute_step, can_view_step)'
      end
      put ':id/permissions' do
        authenticate!
        validate_permission!(:manage, Flow)

        permission_type = safe_params[:permission_type]
        types           = %w{can_execute_step can_view_step}

        step_id = safe_params[:id].to_i
        group_ids = safe_params[:group_ids] ? safe_params[:group_ids].map { |id| id.to_i } : []

        error!(I18n.t(:permission_type_not_included), 400) unless types.include? permission_type

        # Add permissions to the groups indicated on the request
        group_ids.each do |group_id|
          group = Group.find(group_id)
          Groups::PermissionManager.new(group).add_with_objects(permission_type, [step_id])
        end

        # Remove permission to groups that are not present on the request
        Group.that_includes_permission(permission_type, step_id)
             .reject { |g| group_ids.include?(g.id) }
             .each { |g| Groups::PermissionManager.new(g).remove_with_objects(permission_type, [step_id]) }

        { message: I18n.t(:permissions_updated) }
      end

      desc 'Get specific version of Step'
      params { optional :display_type, type: String, desc: 'Display type for Step' }
      get ':id/versions/:step_version' do
        authenticate!
        validate_permission!(:view, Step)

        step = Flow.find(safe_params[:flow_id]).steps.find(safe_params[:id]).version(safe_params[:step_version].to_i)
        { step: Step::Entity.represent(step, only: return_fields, display_type: safe_params[:display_type]) }
      end

      mount Flows::Steps::Fields::API
      mount Flows::Steps::Triggers::API
    end
  end
end

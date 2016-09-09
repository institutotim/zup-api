module Cases
  class API < Base::API
    helpers CaseHelper

    resources :cases do
      desc 'Create a Case'
      params do
        requires :initial_flow_id,      type: Integer, desc: 'ID of Initial Flow'
        optional :fields,               type: Array,   desc: 'Array of hash with id of field and value'
        optional :responsible_user_id,  type: Integer, desc: 'Responsible User ID'
        optional :responsible_group_id, type: Integer, desc: 'Responsible Group ID'
      end
      post do
        authenticate!

        initial_flow = Flow.find_initial(safe_params[:initial_flow_id])
        initial_flow = initial_flow.the_version(nil, initial_flow.versions.last.id)
        step = initial_flow.get_new_step_to_case

        return error!(I18n.t(:flow_not_published), 400) if initial_flow.version.blank?
        return error!(I18n.t(:step_not_found), 404)     unless step.try(:active)

        validate_permission!(:create, initial_flow.cases.build.case_steps.build(step: step))

        case_params = safe_params.permit(:initial_flow_id, :responsible_user_id,
          :responsible_group_id, fields: [])

        case_params[:namespace_id] = app_namespace_id

        service = Cases::Create.new(initial_flow, step, current_user, case_params)
        kase = service.create!

        {
          message: I18n.t(:case_created),
          case: Case::Entity.represent(kase, only: return_fields, display_type: 'full')
        }
      end

      desc 'Get all Cases'
      paginate per_page: 25
      params do
        optional :query,               type: String,  desc: 'Query of search'
        optional :initial_flow_id,     type: String,  desc: 'String with of Initial Flows ID, split by comma'
        optional :step_id,             type: String,  desc: 'String with of Steps ID, split by comma'
        optional :resolution_state_id, type: String,  desc: 'String with of Resolution State ID, split by comma'
        optional :completed,           type: Boolean, desc: 'true to filter Case with status equals "finished" or "inactive"'
        optional :mine,                type: Boolean, desc: 'Only return cases which I\'m currently responsible for'
        optional :sort,                type: String,  desc: 'The field to sort the cases. Valid fields: resolution_state, updated_at, created_at, responsible_user'
        optional :order,               type: String,  desc: 'The order, can be `desc` or `asc`'
        optional :display_type,        type: String,  desc: 'Display type for Case'
        optional :just_user_can_view,  type: Boolean, desc: 'To return all items or only title because user can\'t view (true by default)'
      end
      get do
        authenticate!

        columns_permitted = ['resolution_state', 'updated_at', 'created_at', 'responsible_user']
        order = safe_params[:order] if ['asc', 'desc'].include? safe_params[:order]
        sort  = safe_params[:sort] if columns_permitted.include? safe_params[:sort]

        order ||= 'asc'
        sort  ||= 'id'

        if 'resolution_state'.eql?(sort)
          kases = Case.joins(:resolution_state, :case_steps, :steps, :initial_flow, :namespace).order("resolution_states.title #{order.upcase}")
        else
          kases = Case.order(sort => order.to_sym)
        end

        # Filtering by query
        if safe_params[:query].present?
          kases = kases.search(safe_params[:query])
        end

        if safe_params[:mine]
          kases = kases.where(responsible_user: current_user.id)
        end

        # Filtering by flows
        if filter_params[:initial_flow_id].present?
          kases = kases.where(initial_flow_id: filter_params[:initial_flow_id])
        end

        # Filtering by resolution state
        if filter_params[:resolution_state_id].present?
          kases = kases.where(resolution_state_id: filter_params[:resolution_state_id])
        end

        # Filtering by status
        if safe_params.has_key? :completed
          if safe_params[:completed]
            kases = kases.where(status: ['finished'])
          else
            kases = kases.where.not(status: ['inactive', 'finished'])
          end
        end

        # Filtering by steps
        if filter_params[:step_id].present?
          kases = kases.joins(:case_steps).where('case_steps.steps' => filter_params[:step_id])
        end

        # Filtering by permissions
        if user_permissions.cannot?(:manage, Case)
          kases = kases.where('source_reports_category_id' => user_permissions.cases_visible)
          params[:cases_visible] = user_permissions.cases_visible
        end

        kases = paginate(kases)

        garner.bind(
          CustomCacheControl.new(Case, current_user, app_namespace_id, params)
        ).options(expires_in: 1.day) do
          result = {
            cases: Case::Entity.represent(
              kases,
              only: return_fields,
              display_type: safe_params[:display_type],
              just_user_can_view: (safe_params[:just_user_can_view] || true),
              current_user: current_user
            )
          }

          Oj.load(result.to_json)
        end
      end

      resources ':id' do
        desc 'Get Case'
        params do
          optional :display_type,       type: String,  desc: 'Display type for Case'
          optional :just_user_can_view, type: Boolean, desc: 'To return all items or only title because user can\'t view (true by default)'
        end
        get do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          validate_permission!(:show, kase)

          { case: Case::Entity.represent(kase, only: return_fields, display_type: safe_params[:display_type],
                                        just_user_can_view: (safe_params[:just_user_can_view] || true),
                                        current_user: current_user) }
        end

        desc 'Inactive Case'
        delete do
          authenticate!
          kase = Case.active.find(safe_params[:id])
          validate_permission!(:delete, kase)

          kase.update!(old_status: kase.status, status: 'inactive', updated_by: current_user)
          kase.log!('delete_case', user: current_user)

          { message: I18n.t(:case_deleted) }
        end

        desc 'Restore Case'
        put '/restore' do
          authenticate!
          kase = Case.inactive.find(safe_params[:id])
          validate_permission!(:restore, kase)

          kase.update!(status: kase.old_status, old_status: nil, updated_by: current_user)
          kase.log!('restored_case', user: current_user)

          { message: I18n.t(:case_restored) }
        end

        desc 'Update/Next Step Case'
        params do
          requires :step_id,              type: Integer, desc: 'Step ID'
          optional :fields,               type: Array,   desc: 'Array of hash with if of field and value'
          optional :responsible_user_id,  type: Integer, desc: 'Responsible User ID'
          optional :responsible_group_id, type: Integer, desc: 'Responsible Group ID'
        end
        put do
          authenticate!

          kase = Case.not_inactive.find(safe_params[:id])
          return error!(I18n.t(:step_is_disabled), 400) if kase.disabled_steps.include?(safe_params[:step_id])
          step = kase.initial_flow.find_step_on_list(safe_params[:step_id])
          return error!(I18n.t(:step_is_not_of_case), 400) if step.blank?

          case_step = kase.case_steps.find_by(step_id: safe_params[:step_id])

          service = Cases::UpdateOrCreateNextStep.new(
            kase: kase,
            case_step: case_step,
            fields_params: fields_params,
            user: current_user,
            step: step,
            params: params
          )

          if case_step.present?
            validate_permission!(:update, service.case_step)
            message = service.update!
          else
            validate_permission!(:create, service.case_step)
            message = service.create!
          end

          {
            message: message,
            case: Case::Entity.represent(kase, only: return_fields, display_type: 'full'),
          }
        end

        desc 'To Finish Case'
        params { requires :resolution_state_id, type: Integer, desc: 'Resolution State ID' }
        put '/finish' do
          authenticate!
          kase = Case.not_inactive.find(safe_params[:id])
          return { message: I18n.t(:case_is_already_finished) } if kase.status == 'finished'
          validate_permission!(:update, kase)

          kase.update!(status: 'finished', resolution_state_id: safe_params[:resolution_state_id])
          kase.log!('finished', user: current_user)

          { message: I18n.t(:finished_case) }
        end

        desc 'Get Case History'
        params { optional :display_type, type: String,  desc: 'Display type for CasesLogEntry' }
        get '/history' do
          authenticate!
          kase = Case.find(safe_params[:id])
          validate_permission!(:show, kase)

          { cases_log_entries: CasesLogEntry::Entity.represent(kase.cases_log_entries, only: return_fields,
                                                              display_type: safe_params[:display_type]) }
        end

        resources '/case_steps' do
          desc 'Update Step of Case'
          params do
            optional :responsible_user_id,  type: Integer, desc: 'User ID'
            optional :responsible_group_id, type: Integer, desc: 'Group ID'
          end
          put ':case_step_id' do
            authenticate!
            case_step = CaseStep.find(safe_params[:case_step_id])
            validate_permission!(:update, case_step)

            log_params    = {}
            before_update = case_step.dup
            parameters    = safe_params.permit(:responsible_user_id, :responsible_group_id)
            case_step.update!({ updated_by: current_user }.merge(parameters))

            if safe_params.has_key?(:responsible_user_id)
              log_params.merge!(before_user_id: before_update.responsible_user_id,
                                after_user_id: safe_params[:responsible_user_id])
            end
            if safe_params.has_key?(:responsible_group_id)
              log_params.merge!(before_group_id: before_update.responsible_group_id,
                                after_group_id: safe_params[:responsible_group_id])
            end
            if safe_params.has_key?(:responsible_user_id) || safe_params.has_key?(:responsible_group_id)
              case_step.case.log!('transfer_case', log_params.merge(user: current_user))
            end

            { message: I18n.t(:case_step_updated) }
          end
        end
      end
    end
  end
end

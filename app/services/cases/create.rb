module Cases
  class Create
    attr_reader :initial_flow, :user, :step, :namespace_id, :params

    def initialize(initial_flow, step, user, params = {})
      @initial_flow = initial_flow
      @user = user
      @step = step
      @params = params
      @namespace_id = params.fetch(:namespace_id) { user.namespace_id }
    end

    def create!
      case_step_params = {
        created_by: user,
        step: step,
        step_version: step.versions.last.id
      }

      if params[:fields].present?
        case_step_params.merge!(responsible_user_id: user.id,
                                case_step_data_fields_attributes: params[:fields])
      else
        if params[:responsible_user_id].present?
          case_step_params.merge!(responsible_user_id: params[:responsible_user_id])
        elsif params[:responsible_group_id].present?
          case_step_params.merge!(responsible_group_id: params[:responsible_group_id])
        else
          case_step_params.merge!(responsible_user_id: user.id)
        end
      end

      kase_params = {
        created_by: user,
        case_steps_attributes: [case_step_params],
        flow_version: initial_flow.version.id,
        source_reports_category_id: params[:source_reports_category_id],
        namespace_id: namespace_id
      }

      if params[:responsible_user_id].present?
        kase_params.merge!(responsible_user: params[:responsible_user_id])
      elsif params[:responsible_group_id].present?
        kase_params.merge!(responsible_group: params[:responsible_group_id])
      else
        kase_params.merge!(responsible_user: user.id)
      end

      kase = initial_flow.cases.create!(kase_params)

      kase.log!('create_case', user: user)

      kase
    end
  end
end

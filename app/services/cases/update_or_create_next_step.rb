module Cases
  # Creates a next step or update a step for a case
  class UpdateOrCreateNextStep
    attr_reader :kase, :case_step, :fields_params,
                :params, :user, :options, :step,
                :inventory_item_creator

    def initialize(options = {})
      @options = options
      @kase = options[:kase]
      @fields_params = options[:fields_params]
      @params = options[:params]
      @user = options[:user]
      @step = options[:step]
      @case_step = options[:case_step] || CaseStep.new(kase: kase, step: step)
      @inventory_item_creator = Cases::CreateInventoryItem.new(case_step, user, fields_params)
    end

    def update!
      validate_required_options!(options, [:kase, :case_step, :user])
      fields = prepare_fields_params

      case_step_params = {
        updated_by: user,
        responsible_user_id: nil,
        responsible_group_id: nil,
        case_step_data_fields_attributes: fields
      }

      case_step_params = case_step_params.merge(responsible_params)

      ActiveRecord::Base.transaction do
        case_step.attributes = case_step_params
        inventory_item_creator.save! if inventory_item_creator.should_save?
        inventory_item_creator.set_ids_for_inventory_item_fields!
        case_step.save!
      end

      message = finish_case!

      return message if message
      I18n.t(:update_step_success)
    end

    def create!
      validate_required_options!(options, [:kase, :user, :step])
      fields = prepare_fields_params

      case_step_params = {
        created_by: user,
        step: step,
        step_version: step.versions.last.id,
        case_step_data_fields_attributes: fields
      }

      case_step_params = case_step_params.merge(responsible_params)
      case_step.attributes = case_step_params

      validate_presence_of_current_step!

      kase.updated_by  = user
      kase.case_steps << case_step

      ActiveRecord::Base.transaction do
        inventory_item_creator.save! if inventory_item_creator.should_save?
        kase.save!
      end

      if case_step.case_step_data_fields.blank?
        kase.log!('started_step', user: user)
        message = I18n.t(:started_step_success)
      else
        kase.log!('next_step', user: user)
        message = I18n.t(:next_step_success)
      end

      message ||= finish_case!
      message
    end

    # If current_step exists and you're updating other step, and current_step isn't
    # executed, valid or disabled, raise error
    def validate_presence_of_current_step!
      current_step = kase.case_steps.last

      if current_step.present? && current_step.id != step.id &&
        !(current_step.executed? || current_step.my_step.required_fields.blank?) &&
        !kase.disabled_steps.include?(current_step.id)
        fail I18n.t(:current_step_required)
      end
    end

    def finish_case!
      all_steps       = kase.initial_flow.list_all_steps
      return if all_steps.blank?

      next_step_index = all_steps.index(step).try(:next)
      next_steps      = all_steps[next_step_index..-1]
      message = ''

      if kase.status == 'not_satisfied' || next_steps.blank?
        if kase.steps_not_fulfilled.blank?
          kase.update!(status: 'finished', updated_by: user)
          kase.log!('finished', user: user)
          message = I18n.t(:finished_case)
        else
          kase.update!(status: 'not_satisfied', updated_by: user)
          kase.log!('not_satisfied', user: user)
          message = I18n.t(:case_with_pending_steps)
        end
      end

      message
    end

    private

    def prepare_fields_params
      return unless fields_params.is_a?(Array)
      inventory_item_creator.prepare_fields_params
    end

    def responsible_params
      if params[:responsible_user_id].present?
        { responsible_user_id: params[:responsible_user_id] }
      elsif params[:responsible_group_id].present?
        { responsible_group_id: params[:responsible_group_id] }
      else
        { responsible_user_id: user.id }
      end
    end

    # Check if params required are there and not nil
    def validate_required_options!(options, required_keys)
      interpolated_keys = ((options.reject do |_k, v|
        v.nil?
      end).keys & required_keys)
      missing_keys = required_keys - interpolated_keys

      fail "Parameter(s) `#{missing_keys.map(&:to_s).join(", ")}` missing" if missing_keys.any?
    end
  end
end

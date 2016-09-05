module CaseHelper
  def fields_params
    return [] if safe_params[:fields].blank?
    safe_params[:fields].map { |field| { field_id: field['id'].to_i, value: field['value'] } }
  end

  def split_param(key)
    safe_params[key] && safe_params[key].split(',').map(&:to_i)
  end

  def filter_params
    parameters = {}
    parameters[:initial_flow_id]      = split_param(:initial_flow_id)
    parameters[:resolution_state_id]  = split_param(:resolution_state_id)
    parameters[:step_id]              = split_param(:step_id)
    parameters
  end

  def run_triggers(step, kase)
    trigger_type, trigger_values, trigger_description = nil
    triggers = step.try(:my_triggers, active: true)

    if triggers.present? && fields_params.present?
      triggers.each do |trigger|
        case_step  = kase.case_steps.find_by(step_id: step.id)
        conditions = trigger.my_trigger_conditions(active: true).map do |condition|
          compare_trigger_condition?(condition, case_step.case_step_data_fields)
        end
        unless conditions.include? false
          case_step.update!(trigger_ids: [trigger.id])
          trigger_type        = trigger.action_type
          trigger_values      = trigger.action_values
          trigger_description = trigger.description
          if trigger.action_type == 'finish_flow'
            kase.update!(status: 'finished', resolution_state_id: trigger_values.first)
            all_steps  = kase.initial_flow.list_all_steps
            next_step_index = all_steps.index(case_step.my_step).try(:next)
            if other_case_steps = kase.case_steps.where(step_id: all_steps[next_step_index..-1])
              other_case_steps.delete_all
              kase.log!('removed_case_step', user: current_user)
            end
            kase.log!('finished', user: current_user)
          elsif trigger.action_type == 'disable_steps'
            kase.update! disabled_steps: kase.disabled_steps.push(trigger_values).flatten.uniq.map(&:to_i)
          elsif trigger.action_type == 'transfer_flow'
            kase.log!('transfer_flow', new_flow_id: trigger_values.first, user: current_user)
          end
          break
        end
      end
    end
    { type: trigger_type, value: trigger_values, description: trigger_description }
  end

  def compare_trigger_condition?(condition, data_fields)
    field          = condition.my_field
    original_value = data_fields.find_by(field_id: field.id).try(:value)
    value          = convert_data(field.field_type, original_value, field)
    cond_values    = condition.values.map { |v| convert_data(field.field_type, v, field) }
    case condition.condition_type
    when '=='
      cond_values.first == value
    when '!='
      cond_values.first != value
    when '>'
      cond_values.first > value
    when '<'
      cond_values.first < value
    when 'inc'
      cond_values.include? value
    else
      false
    end
  end

  def convert_data(type, value, elem = nil)
    return value if value.blank?
    data_value = value.is_a?(String) ? value.squish! : value

    case type
    when 'string', 'text'
      data_value = data_value.to_s
    when 'integer', 'year', 'month', 'day', 'hour', 'minute', 'second', 'years', 'months', 'days', 'hours', 'minutes', 'seconds'
      data_value = data_value.to_i
    when 'decimal', 'meter', 'centimeter', 'kilometer', 'decimals', 'meters', 'centimeters', 'kilometers'
      data_value = data_value.to_f
    when 'angle'
      data_value = data_value.to_f
    when 'date'
      data_value = data_value.to_date
    when 'time'
      data_value = data_value.to_time
    when 'date_time'
      data_value = data_value.to_datetime
    when 'email'
      data_value = data_value.downcase
    when 'checkbox', 'select'
      data_value = convert_field_data(data_value)
    when 'image'
      data_value = convert_field_data(data_value)
      elem.value = ''
      elem.update_case_step_data_images data_value
    when 'attachment'
      data_value = convert_field_data(data_value)
      elem.value = ''
      elem.update_case_step_data_attachments data_value
    when 'previous_field'
      #nothing to do
    when 'inventory_item'
      @items_with_update = elem.field.category_inventory.joins(:items).where(inventory_items: { id: eval(data_value) })
      data_value = @items_with_update.map(&:id)
    when 'inventory_field'
      inventory_field = Inventory::Field.find(elem.origin_field_id)
      data_value      = convert_data(inventory_field.kind, data_value)
    when 'report_item'
      #nothing to do
    end
    data_value
  end

  def convert_field_data(field)
    return field unless field.is_a? String
    field =~ /^\[.*\]$/ || field =~ /^\{.*\}$/ ? eval(field) : field
  end
end

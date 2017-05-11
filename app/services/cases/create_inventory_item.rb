module Cases
  # Creates an inventory item from a case step
  class CreateInventoryItem
    attr_reader :case_step, :user, :fields_params,
                :item, :data, :should_save, :kase

    def initialize(case_step, user, fields_params)
      @case_step = case_step
      @kase = case_step.kase
      @fields_params = fields_params
      @user = user
    end

    def prepare_fields_params
      @data = {}

      # Search for all fields which
      # are an inventory item selector
      fields_params.each do |field_data|
        field_id = field_data[:field_id]
        value = field_data[:value]
        field = find_field_in_step(field_id)
        next unless field

        if field.field_type == 'inventory_item'
          @should_save = true

          data[field.id] = {
            action: nil,
            item: nil
          }

          if value.blank?
            data[field.id][:action] = :create
            category = Inventory::Category.find(field.category_inventory_id[0])
            data[field.id][:item] = Inventory::Item.new(
              category: category,
              user: user,
              namespace: kase.namespace
            )
          else
            data[field.id][:action] = :update
            data[field.id][:item] = Inventory::Item.find(value[0])
          end
        end
      end

      fields_params.map do |f|
        case_step_field = case_step.case_step_data_fields.find_by(field_id: f[:field_id])
        field_data = { field_id: f[:field_id] }

        field_data = field_data.merge(id: case_step_field.id) unless case_step_field.nil?
        field_data = field_data.merge(correct_case_step: case_step)

        field = find_field_in_step(f[:field_id])
        if field && %w(inventory_field inventory_item).include?(field.field_type)
          if data[field.field_id]
            field_data = field_data.merge(inventory_item: data[field.field_id][:item])
            field_data = field_data.merge(user: user)
          end
        end

        field_data = field_data.merge(value: f[:value])
        field_data
      end
    end

    def save!
      @data.each do |_field_id, data|
        item = data[:item]
        representer = item.represented_data(user)

        if representer.valid?
          representer.inject_to_data!
          representer.item.save!

          representer.create_history_entry
        else
          fail ActiveRecord::RecordInvalid.new(representer)
        end
      end
    end

    def set_ids_for_inventory_item_fields!
      case_step.case_step_data_fields.each do |csdf|
        if csdf.field.field_type == 'inventory_item' && csdf.inventory_item
          csdf.value = "[#{csdf.inventory_item.id}]"
        end
      end
    end

    def should_save?
      should_save
    end

    def find_field_in_step(field_id)
      step = case_step.kase.my_initial_flow.my_steps.select { |s| s.id == case_step.step_id }.first
      step.my_fields.select { |f| f.id == field_id }.first
    end
  end
end

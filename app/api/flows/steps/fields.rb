module Flows::Steps::Fields
  class API < Base::API
    resources ':step_id/fields' do
      desc 'Get all Fields'
      get do
        authenticate!
        validate_permission!(:view, Field)
        { fields: Field::Entity.represent(Step.find(safe_params[:step_id]).fields, only: return_fields) }
      end

      desc 'Update order of Fields'
      params { requires :ids, type: Array, desc: 'Array with steps ids in order' }
      put do
        authenticate!
        validate_permission!(:update, Field)

        if safe_params[:ids].blank?
          step_fields = Step.find(safe_params[:step_id]).fields

          unless safe_params[:ids].sort == step_fields.map(&:id).sort
            status(400)
            break { error: 'Os campos enviados para ordenação não correspondem os campos existentes na etapa.' }
          end

          step_fields.update_order!(safe_params[:ids], current_user)
          { message: I18n.t(:fields_order_updated) }
        else
          status 200
        end
      end

      desc 'Create a Field'
      params do
        requires :title,                 type: String,  desc: 'Title of Field'
        requires :field_type,            type: String,  desc: 'Type of Field'
        optional :filter,                type: String,  desc: 'Filter for attachment type (ex.: *.pdf,*.txt)'
        optional :origin_field_id,       type: Integer, desc: 'If type is previous_field need to set origin_field_id'
        optional :category_inventory_id, type: Integer, desc: 'Category Inventory ID'
        optional :category_report_id,    type: Integer, desc: 'Category Report ID'
        optional :order_number,          type: Integer, desc: 'Order Number for Field'
        optional :requirements,          type: Hash,    desc: 'Requirements for Field'
        optional :values,                type: Array,   desc: 'Values for choice fields'
        optional :multiple,              type: Boolean, desc: 'If the field supports multiple values'
        optional :field_id,              type: Integer, desc: 'Field to get extra info about'
      end
      post do
        authenticate!
        validate_permission!(:create, Field)

        parameters = safe_params.permit(:title, :field_type, :filter, :origin_field_id, :category_inventory_id, :multiple,
                                        :category_report_id, :field_id, requirements: [:presence, :minimum, :maximum, :multiline])
        parameters.merge!(values: safe_params[:values], user: current_user)

        field = Step.find(safe_params[:step_id]).fields.create!(parameters)
        { message: I18n.t(:field_created), field: Field::Entity.represent(field, only: return_fields) }
      end

      desc 'Update a Field'
      params do
        optional :title,                 type: String,  desc: 'Title of Field'
        optional :field_type,            type: String,  desc: 'Type of Field'
        optional :filter,                type: String,  desc: 'Filter for attachment type (ex.: *.pdf,*.txt)'
        optional :origin_field_id,       type: Integer, desc: 'If type is previous_field need to set origin_field_id'
        optional :category_inventory_id, type: Integer, desc: 'Category Inventory ID'
        optional :category_report_id,    type: Integer, desc: 'Category Report ID'
        optional :order_number,          type: Integer, desc: 'Order Number for Field'
        optional :requirements,          type: Hash,    desc: 'Requirements for Field'
        optional :values,                type: Array,   desc: 'Values for choice fields'
        optional :multiple,              type: Boolean, desc: 'If the field supports multiple values'
        optional :field_id,              type: Integer, desc: 'Field to get extra info about'
      end
      put ':id' do
        authenticate!
        validate_permission!(:update, Field)

        parameters = safe_params.permit(:title, :field_type, :filter, :origin_field_id, :category_inventory_id, :multiple,
                                        :category_report_id, :field_id, requirements: [:presence, :minimum, :maximum, :multiline])
        parameters.merge!(values: safe_params[:values], user: current_user)

        field = Step.find(safe_params[:step_id]).fields.find(safe_params[:id])
        field.update!(parameters)

        { message: I18n.t(:field_updated), field: Field::Entity.represent(field.reload, only: return_fields) }
      end

      desc 'Delete a Field'
      delete ':id' do
        authenticate!
        validate_permission!(:delete, Field)

        field = Step.find(safe_params[:step_id]).fields.find(safe_params[:id])
        field.user = current_user
        field.inactive!

        { message: I18n.t(:field_deleted) }
      end
    end
  end
end

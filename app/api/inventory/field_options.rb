module Inventory::FieldOptions
  class API < Base::API
    helpers do
      def load_field(field_id = nil)
        Inventory::Field.find(
          field_id || safe_params[:field_id]
        )
      end
    end

    namespace :fields do
      route_param :field_id do
        resource :options do
          desc 'List all options for an field'
          get do
            authenticate!
            field = load_field

            validate_permission!(:view, field.category)

            {
              field_options: Inventory::FieldOption::Entity.represent(field.field_options.enabled.sorted)
            }
          end

          desc 'Create an option for a field'
          params do
            requires :value, desc: 'The value for the option'
          end
          post do
            authenticate!
            field = load_field

            validate_permission!(:edit, field.category)

            unless safe_params[:value].is_a?(Array)
              field_option_params = safe_params.permit(:value)
              field_option = field.field_options.create!(field_option_params)

              {
                field_option: Inventory::FieldOption::Entity.represent(field_option)
              }
            else
              safe_params[:value].each do |value|
                field.field_options.build(value: value)
                field.save!
              end

              {
                field_options: Inventory::FieldOption::Entity.represent(field.field_options)
              }
            end
          end

          route_param :id do
            desc 'Get info about a specific field option'
            get do
              authenticate!
              field = load_field

              validate_permission!(:view, field.category)
              field_option = field.field_options.find(params[:id])

              {
                field_option: Inventory::FieldOption::Entity.represent(field_option)
              }
            end

            desc 'Updates an option for a field'
            params do
              requires :value, desc: 'The value for the option'
            end
            put do
              authenticate!
              field = load_field

              validate_permission!(:edit, field.category)

              field_option = field.field_options.find(params[:id])

              field_option_params = safe_params.permit(:value)
              field_option.update!(field_option_params)

              {
                field_option: Inventory::FieldOption::Entity.represent(field_option)
              }
            end

            desc 'Removes an option for a field'
            delete do
              authenticate!
              field = load_field

              validate_permission!(:edit, field.category)

              field_option = field.field_options.find(params[:id])
              field_option.disable!

              {
                message: 'Field option removed successfully'
              }
            end
          end
        end
      end
    end
  end
end

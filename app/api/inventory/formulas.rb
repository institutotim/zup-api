module Inventory::Formulas
  class API < Base::API
    helpers do
      def load_category(inventory_category_id = nil)
        Inventory::Category.find(inventory_category_id || safe_params[:category_id])
      end
    end

    namespace :categories do
      route_param :category_id do
        # /inventory/categories/:id/formulas
        resource :formulas do
          desc 'Get all formulas for the category'
          get do
            authenticate!
            validate_permission!(:view, Inventory::Formula)

            category = load_category
            present category.formulas, using: Inventory::Formula::Entity
          end

          desc 'Create a new formula for the category'
          params do
            requires :category_id, type: Integer
            requires :inventory_status_id, type: Integer
            requires :conditions, type: Array
            optional :groups_to_alert, type: Array
            optional :run_formula, type: Boolean, desc: 'Should this run for existent items? Default: false'
          end
          post do
            authenticate!
            validate_permission!(:create, Inventory::Formula)

            category = load_category

            status = category.statuses.find(params[:inventory_status_id])
            formula = category.formulas.build

            # Conditions
            #
            # It accepts a hash like this:
            #
            #   {
            #     ...
            #     "conditions": [
            #       {
            #         "conditionable_id": 123,
            #         "conditionable_type": "Inventory::Field"
            #         "operator": "equal_to",
            #         "content": "test"
            #       }
            #     ]

            formula.status = status
            if params[:groups_to_alert].present?
              formula.groups_to_alert = params[:groups_to_alert].map(&:to_i)
            end
            formula.conditions_attributes = params[:conditions]
            formula.save!

            if params[:run_formula] == true
              ExecuteFormulaForCategory.perform_async(current_user.id, formula.id)
            end

            present formula, using: Inventory::Formula::Entity
          end

          desc 'Updates a formula'
          params do
            requires :category_id, type: Integer
            optional :inventory_status_id, type: Integer
            optional :conditions, type: Array
            optional :groups_to_alert, type: Array
          end
          put ':formula_id' do
            authenticate!
            validate_permission!(:create, Inventory::Formula)

            category = load_category

            formula = category.formulas.find(params[:formula_id])

            formula_params = safe_params.permit(:inventory_status_id)

            unless params[:conditions].blank?
              formula_params[:conditions_attributes] = params[:conditions]
            end

            unless params[:groups_to_alert].blank?
              formula_params[:groups_to_alert] = params[:groups_to_alert].map(&:to_i)
            end

            formula.update!(formula_params)

            present formula, using: Inventory::Formula::Entity
          end

          desc 'Destroy a formula'
          delete ':formula_id' do
            authenticate!
            validate_permission!(:delete, Inventory::Formula)

            category = load_category
            formula = category.formulas.find(params[:formula_id])
            formula.destroy!

            if formula && formula.destroy
              { message: 'Formula destroyed sucessfully' }
            else
              error!('Formula not found', 404)
            end
          end

          route_param :formula_id do
            resources :alerts do
              desc 'List affected items by an alert'
              get ':alert_id' do
                authenticate!
                validate_permission!(:view, Inventory::Formula)

                category = load_category
                formula = category.formulas.find(params[:formula_id])
                alert = formula.alerts.find(params[:alert_id])

                present alert, using: Inventory::FormulaAlert::Entity
              end
            end
          end
        end
      end
    end
  end
end

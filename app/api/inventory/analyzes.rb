module Inventory::Analyzes
  class API < Base::API
    helpers do
      def load_category(inventory_category_id = nil)
        Inventory::Category.find(inventory_category_id || safe_params[:category_id])
      end
    end

    namespace :categories do
      route_param :category_id do
        # /inventory/categories/:id/analyzes
        resources :analyzes do
          desc 'Get all analyzes for the category'
          get do
            authenticate!

            category = load_category

            {
              analyzes: Inventory::Analysis::Entity.represent(category.analyzes, only: safe_params[:return_fields])
            }
          end

          desc 'Create a new analysis'
          params do
            requires :title, type: String, desc: 'The title of analysis'
            requires :expression, type: String, desc: 'The expression to calculate score total'
            optional :scores, type: Array, desc: 'The scores table'
          end
          post do
            authenticate!

            create_params = safe_params.permit(:title, :expression, scores: [:id, :inventory_field_id, :operator, :content, :score])
            create_params[:scores_attributes] = create_params.delete(:scores) if create_params.key?(:scores)

            category = load_category
            analysis = category.analyzes.create!(create_params)

            {
              analysis: Inventory::Analysis::Entity.represent(analysis)
            }
          end

          desc 'Update a analysis'
          params do
            optional :title, type: String, desc: 'The title of analysis'
            optional :expression, type: String, desc: 'The expression to calculate score total'
            optional :scores, type: Array, desc: 'The scores table'
          end
          put ':id' do
            authenticate!

            analysis = Inventory::Analysis.find(safe_params[:id])

            update_params = safe_params.permit(:title, :expression, scores: [:id, :inventory_field_id, :operator, :content, :score, '_destroy'])
            update_params[:scores_attributes] = update_params.delete(:scores) if update_params.key?(:scores)

            analysis.update!(update_params)

            {
                analysis: Inventory::Analysis::Entity.represent(analysis)
            }
          end

          desc 'Delete a analysis'
          delete ':id' do
            authenticate!

            analysis = Inventory::Analysis.find(safe_params[:id])
            analysis.destroy!
          end
        end
      end
    end
  end
end

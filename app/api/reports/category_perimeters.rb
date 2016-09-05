module Reports
  module CategoryPerimeters
    class API < Grape::API
      helpers do
        def load_category_perimeter(category_perimeter_id = params[:id])
          Reports::CategoryPerimeter.find(category_perimeter_id)
        end

        def load_category(category_id = params[:category_id])
          Reports::Category.find(category_id)
        end

        def load_group(group_id = params[:group_id])
          Group.find(group_id)
        end

        def load_perimeter(perimeter_id = params[:perimeter_id])
          Reports::Perimeter.find(perimeter_id)
        end
      end

      namespace 'categories/:category_id/perimeters' do
        desc 'Create a new category perimeter'
        params do
          requires :group_id, type: Integer,
            desc: 'The ID of the solver group'
          requires :perimeter_id, type: Integer,
            desc: 'The ID of the perimeter'
          optional :active, type: Boolean, default: true,
            desc: 'Active or disable report perimeter'
          optional :priority, type: Integer, default: 0,
            desc: 'Priority of report from higher to lesser'
        end
        post do
          authenticate!

          category  = load_category
          group     = load_group
          perimeter = load_perimeter

          category_perimeter = Reports::CategoryPerimeter.create!(
            category: category,
            group: group,
            perimeter: perimeter,
            namespace_id: app_namespace_id,
            active: safe_params[:active],
            priority: safe_params[:priority]
          )

          {
            perimeter: Reports::CategoryPerimeter::Entity.represent(
              category_perimeter,
              only: return_fields
            )
          }
        end

        desc 'List all category perimeters of a category'
        get do
          authenticate!

          category = load_category
          categories_perimeters = category.category_perimeters.eager_load(
            :group, :perimeter
          )

          categories_perimeters.where(namespace_id: app_namespace_id)

          {
            perimeters: Reports::CategoryPerimeter::Entity.represent(
              categories_perimeters,
              only: return_fields
            )
          }
        end

        desc "Shows category perimeter's info"
        get ':id' do
          authenticate!

          category_perimeter = load_category_perimeter

          {
            perimeter: Reports::CategoryPerimeter::Entity.represent(
              category_perimeter,
              only: return_fields
            )
          }
        end

        desc 'Update category perimeter'
        params do
          requires :group_id, type: Integer,
            desc: 'The ID of the solver group'
          requires :perimeter_id, type: Integer,
            desc: 'The ID of the perimeter'
          optional :active, type: Boolean, default: true,
            desc: 'Active or disable report perimeter'
          optional :priority, type: Integer, default: 0,
            desc: 'Priority of report from higher to lesser'
        end
        put ':id' do
          authenticate!

          category           = load_category
          group              = load_group
          perimeter          = load_perimeter
          category_perimeter = load_category_perimeter

          category_perimeter.update!(
            category: category,
            group: group,
            perimeter: perimeter,
            active: safe_params[:active],
            priority: safe_params[:priority]
          )

          {
            perimeter: Reports::CategoryPerimeter::Entity.represent(
              category_perimeter,
              only: return_fields
            )
          }
        end

        desc 'Delete category perimeter'
        delete ':id' do
          authenticate!

          category_perimeter = load_category_perimeter

          if category_perimeter.destroy
            status 204
          else
            status 422
          end
        end
      end
    end
  end
end

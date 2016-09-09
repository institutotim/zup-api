module Reports::Categories
  class API < Base::API
    resource :categories do
      desc 'Creates a new report category'
      params do
        requires :title, type: String,
                 desc: 'The report category title'

        requires :icon, type: String,
                 desc: 'The icon that represents this category. Used for listing.'

        requires :marker, type: String,
                 desc: 'The marker used on the map for reports of this category.'

        requires :statuses, category_status: true,
                 desc: 'A JSON hash of statuses that reports from this categories allows.
                 Accepts the properties: title [String], color [#hexa String], initial [Bool] and final [Bool]'

        requires :color, type: String,
                 desc: 'A hex color string that will be used as background color for the icons ' +
                 'and markers of this category'

        optional :priority, type: String,
                 desc: 'A priority of visualization. Used for listing and visualization.
                 Accepts the values: low, medium and high'

        optional :resolution_time, type: Integer,
                 desc: 'The time this kind of report takes to be solved, in seconds.'

        optional :private_resolution_time, type: Boolean,
                 desc: 'If the resolution time should be private for the public user'

        optional :resolution_time_enabled, type: Boolean,
                 desc: 'If the resolution time is enabled or not for the category'

        optional :user_response_time, type: Integer,
                 desc: 'How long the user is allowed to comment on this report after ' +
                 'it has been marked as resolved, in seconds'

        optional :allows_arbitrary_position, type: Boolean,
                 desc: 'Whether or not to allow the user to set a custom marker location for the reports of this category'

        optional :inventory_categories, type: Array,
                 desc: 'Array of related inventory categories'

        optional :parent_id, type: Integer,
                 desc: 'The id of a parent category (this will become a subcategory)'

        optional :confidential, type: Boolean,
                 desc: 'If the reports created on this category are confidential or not'

        optional :solver_groups_ids, type: Array,
                 desc: 'Array of groups ids that are solver for this report category'

        optional :default_solver_group_id, type: Integer,
                 desc: 'Group id for the default solver group'

        optional :comment_required_when_forwarding, type: Boolean,
                 desc: 'Requires internal comment when forwarding to other group'

        optional :comment_required_when_updating_status, type: Boolean,
                 desc: 'Requires comment when updating item status'

        optional :notifications, type: Boolean,
                 desc: 'Enables or disables notification feature for categories'

        optional :ordered_notifications, type: Boolean,
                 desc: 'Enables or disables the requirement for ordered notifications (if notifications is enabled)'

        optional :perimeters, type: Boolean,
                 desc: 'Enables or disables perimeter feature for categories'

        optional :custom_fields, type: Array,
                 desc: 'Array of custom field objects'

        optional :flow_id, type: Integer,
                 desc: 'The flow id to be used when opening a case through status'

        optional :without_cache, type: Boolean,
                 desc: 'Should not return cached content?'

        optional :global, type: Boolean, default: false,
                 desc: 'Define if category is global or not'
      end

      post do
        authenticate!
        validate_permission!(:create, Reports::Category)

        category_params = safe_params
        category_params[:marker] = category_params[:icon]

        if !category_params[:global] && !current_namespace.default?
          category_params[:namespace_id] = app_namespace_id
        end

        service = Reports::ManageCategory.new
        service.create!(category_params)

        {
          category: Reports::Category::Entity.represent(
            service.category, display_type: :full, only: return_fields
          )
        }
      end

      desc 'Return information about the given category'
      params do
        requires :id, type: Integer, desc: 'The report category ID'
      end
      get ':id' do
        report_category = Reports::Category.find(params[:id])
        report_category.status_categories.reload
        report_category.setting.reload

        validate_permission!(:view, report_category)

        display_type = params[:display_type].nil? ? :full : params[:display_type].to_s.to_sym
        { category: Reports::Category::Entity.represent(report_category, display_type: display_type, only: return_fields) }
      end

      desc 'Returns list of all reports category'
      params do
        optional :subcategories_flat, type: Boolean,
                 desc: 'Return subcategories with categories'
        optional :creatable, type: Boolean,
                 desc: 'Return only categories that current user can create reports'
      end
      get do
        user = current_user || User::Guest.new

        permissions = UserAbility.for_user(user)

        unless permissions.can?(:manage, Reports::Category)
          params[:categories_visible] =
            if params[:creatable]
              permissions.reports_categories_creatable
            else
              permissions.reports_categories_visible
            end
        end

        garner.bind(
          CustomCacheControl.new(Reports::Category, user, app_namespace_id, params)
        ).options(expires_in: 1.day) do
          display_type = params[:display_type].to_sym if params[:display_type]
          subcategories_flat = params[:subcategories_flat]

          include_args = [:inventory_categories, :statuses, subcategories: [:inventory_categories, :statuses, :subcategories]]

          categories_scope = Reports::Category.active
          categories_scope = categories_scope.main unless subcategories_flat
          categories_scope = categories_scope.includes(*include_args)

          if params[:categories_visible]
            categories_scope = categories_scope.where(id: params[:categories_visible])
          end

          {
            categories: Reports::Category::Entity.represent(
              categories_scope,
              only: return_fields,
              display_type: display_type,
              user: user
            )
          }.as_json
        end
      end

      desc 'Updates a report category'
      params do
        requires :id, type: Integer, desc: "The category's ID"
      end
      put ':id' do
        authenticate!

        category = Reports::Category.find(params[:id])
        validate_permission!(:edit, category)

        service = Reports::ManageCategory.new(category)
        service.update!(app_namespace_id, safe_params)

        {
          category: service.category.entity(
            display_type: :full,
            only: return_fields,
            user: current_user
          )
        }
      end

      desc 'Destroy a report category'
      delete ':id' do
        authenticate!

        category = Reports::Category.find(params[:id])
        validate_permission!(:delete, category)
        category.destroy

        Garner.config.cache.delete_matched('reports/category*')

        status 204
      end
    end
  end
end

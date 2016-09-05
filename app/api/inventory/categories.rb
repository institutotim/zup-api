module Inventory::Categories
  class API < Base::API
    resources :categories do
      desc 'List all categories'
      paginate(per_page: 25)
      params do
        optional :title, type: String, desc: "Category's name for search"
        optional :display_type, type: String, desc: 'Display type for the categories'
      end
      get do
        validate_permission!(:view, Inventory::Category)

        garner.bind(CustomCacheControl.new(Inventory::Category, current_user, app_namespace_id, params)).options(expires_in: 1.day) do
          title = safe_params[:title]
          permissions = UserAbility.for_user(current_user)

          categories = Inventory::Category.includes(:namespace, :statuses,
            :sections, sections: [{ fields: :field_options }])

          unless permissions.can?(:manage, Inventory::Category)
            categories = categories.where(id: permissions.inventory_categories_visible)
          end

          if title
            categories = categories.fuzzy_search(title: "%#{title}%")
          end

          {
            categories: Inventory::Category::Entity.represent(
              paginate(categories),
              user: current_user,
              display_type: 'full',
              only: return_fields
            )
          }.as_json
        end
      end

      desc 'Create an category'
      params do
        requires :title, type: String, desc: "Category's name"
        optional :description, type: String, desc: "Category's short description"
        requires :plot_format, type: String, desc: "The format of plotting, can be 'marker' or 'pin'"
        requires :icon, type: String,
          desc: 'The icon that represents this category. Used for listing.'
        requires :color, type: String,
          desc: 'Color of the category'
        optional :require_item_status, type: Boolean,
          desc: 'Defines if item of category should have a status'
        optional :sections, type: Array, desc: "An array of sections and it's fields"
        optional :statuses, type: Array, desc: 'An array of statuses, fields required: title and color'
        optional :groups_can_view, type: Array, desc: 'An array of groups ids'
        optional :groups_can_edit, type: Array, desc: 'An array of groups ids'
        optional :global, type: Boolean, default: false, desc: 'Define if category is global or not'
      end
      post do
        authenticate!
        validate_permission!(:create, Inventory::Category)

        params[:marker] = params[:icon]
        params[:pin] = params[:icon]

        if params[:statuses]
          params[:statuses_attributes] = params[:statuses]
        end

        category_params = safe_params.permit(
          :title, :description, :color, :plot_format, :icon,
          :require_item_status, :private, :marker, :pin,
          statuses_attributes: [:title, :color]
        )

        if !safe_params[:global] && !current_namespace.default?
          category_params[:namespace_id] = app_namespace_id
        end

        category = Inventory::Category.new(category_params)
        category.save!

        if safe_params[:section].present?
          creator = Inventory::CreateFormForCategory.new(category, safe_params)
          category = creator.create!
        end

        permissions = safe_params[:permissions]
        if permissions
          groups_can_view = permissions[:groups_can_view]
          groups_can_edit = permissions[:groups_can_edit]
        end

        Groups::UpdatePermissions.update(groups_can_view, category, :inventories_items_read_only)
        Groups::UpdatePermissions.update(groups_can_edit, category, :inventories_categories_edit)

        {
          message: 'Category created with success',
          category: Inventory::Category::Entity.represent(category, only: return_fields, user: current_user)
        }
      end

      desc "Shows category's info"
      params do
        optional :display_type, type: String,
                 desc: 'If "full", returns additional control properties.'
      end
      get ':id' do
        category = Inventory::Category.includes(sections: :fields)
                                      .find(safe_params[:id])
        validate_permission!(:view, category)

        {
          category: Inventory::Category::Entity.represent(
            category,
            display_type: safe_params[:display_type],
            user: current_user,
            only: return_fields
          )
        }
      end

      desc 'Destroy category'
      delete ':id' do
        authenticate!

        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:delete, category)
        category.destroy

        Garner.config.cache.delete_matched('inventory/category*')

        { message: 'Category deleted successfully' }
      end

      desc "Update category's info"
      params do
        optional :title, type: String, desc: "Category's title"
        optional :description, type: String, desc: "Category's title"
        optional :plot_format, type: String, desc: "The format of plotting, can be 'marker' or 'pin'"
        optional :icon, type: String,
          desc: 'The icon that represents this category. Used for listing.'
        optional :color, type: String, desc: 'Color of the category'
        optional :require_item_status, type: Boolean,
          desc: 'Defines if item of category should have a status'
        optional :groups_can_view, type: Array, desc: 'An array of groups ids'
        optional :groups_can_edit, type: Array, desc: 'An array of groups ids'
        optional :namespace_id, type: Integer, desc: 'Namespace ID'
      end
      put ':id' do
        authenticate!

        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:edit, category)

        category_params = safe_params.permit(
          :title, :description, :color, :plot_format, :require_item_status,
          :private
        )

        category_params[:namespace_id] = app_namespace_id

        category_params = category_params.merge(
          icon: params[:icon],
          marker: params[:icon],
          pin: params[:icon],
        )

        old_color = category.color
        category.update!(category_params)

        if params[:icon] || (params[:color] && params[:color] != old_color)
            category.icon.recreate_versions!
            category.pin.recreate_versions!
            category.marker.recreate_versions!
            category.save!
        end

        permissions = safe_params[:permissions]

        if permissions
          groups_can_view = permissions[:groups_can_view]
          groups_can_edit = permissions[:groups_can_edit]
        end

        Groups::UpdatePermissions.update(groups_can_view, category, :inventories_items_read_only)
        Groups::UpdatePermissions.update(groups_can_edit, category, :inventories_categories_edit)

        {
          message: 'Category updated successfully',
          category: Inventory::Category::Entity.represent(category, user: current_user)
        }
      end

      desc 'Changes the form for the category'
      params do
        requires :sections, type: Array[Hash], desc: "An array of sections and it's fields"
      end
      put ':id/form' do
        authenticate!
        category = Inventory::Category.find(safe_params.delete(:id))
        validate_permission!(:edit, category)

        if !category.locked? || (category.locked? && category.locker == current_user)
          creator = Inventory::CreateFormForCategory.new(category, safe_params)
          category = creator.create!

          form = Inventory::RenderCategoryFormData.new(category, current_user).render

          {
            message: 'Form updated successfully!',
            form: form
          }
        else
          {
            message: 'Form locked',
            locker: User::Entity.represent(category.locker),
            locked_at: category.locked_at
          }
        end
      end

      desc 'Get the form structure for category'
      get ':id/form' do
        authenticate!
        category = Inventory::Category.includes(sections: :fields)
                                      .find(safe_params[:id])
        validate_permission!(:edit, category)

        Inventory::RenderCategoryFormData.new(category, current_user).render
      end

      desc 'Update the access to the inventory category, locking it'
      patch ':id/update_access' do
        authenticate!

        category = Inventory::Category.find(safe_params[:id])
        validate_permission!(:edit, category)

        Inventory::CategoryLocking.new(category, current_user).lock!
      end
    end
  end
end

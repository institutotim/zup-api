module Reports
  class ManageCategory
    attr_reader :category, :params, :old_color

    def initialize(category = Reports::Category.new)
      @category = category
      @old_color = category.color
    end

    def create!(params = {})
      @params = ActionController::Parameters.new(params)

      Reports::Category.transaction do
        category.update!(build_category_params)
        create_namespaces_settings_and_statuses
      end
    end

    def update!(namespace_id, params = {})
      @params = ActionController::Parameters.new(params)

      Reports::Category.transaction do
        category.update!(build_category_params)

        update_statuses(namespace_id)
        update_category_icons
        update_or_create_settings(namespace_id)
      end
    end

    private

    def create_namespaces_settings_and_statuses
      Namespace.find_each do |namespace|
        update_or_create_settings(namespace.id)
        update_statuses(namespace.id)
      end
    end

    def update_or_create_settings(namespace_id)
      setting = category.settings.find_or_create_by(namespace_id: namespace_id)
      setting.update!(build_settings_params)
    end

    def update_statuses(namespace_id)
      statuses_params = build_statuses_params(namespace_id)

      unless statuses_params.blank?
        category.update_statuses!(statuses_params)
      end
    end

    def update_category_icons
      if params[:icon] || (params[:color] && params[:color] != old_color)
        category.icon.recreate_versions!
        category.marker.recreate_versions!
        category.save!
      end
    end

    def build_category_params
      category_params = params.permit(:title, :color, :icon, :marker, :parent_id,
        :namespace_id)

      category_params[:marker] = category_params[:icon]

      fields_params = params.permit(
        custom_fields: [:id, :title, :multiline, :_destroy]
      )

      unless fields_params.blank?
        category_params[:custom_fields_attributes] = fields_params[:custom_fields]
      end

      if params[:inventory_categories]
        category_params.merge!(
          inventory_category_ids: params[:inventory_categories]
        )
      end

      category_params
    end

    def build_settings_params
      @settings_params ||= params.permit(
        :resolution_time_enabled, :resolution_time, :private_resolution_time,
        :user_response_time, :allows_arbitrary_position, :confidential,
        :default_solver_group_id, :comment_required_when_forwarding,
        :comment_required_when_updating_status, :notifications,
        :ordered_notifications, :perimeters, :flow_id, :priority,
        solver_groups_ids: []
      )
    end

    def build_statuses_params(namespace_id)
      return [] if params[:statuses].nil?

      params[:statuses].map do |_k, status|
        status[:namespace_id] = namespace_id
        status
      end
    end
  end
end

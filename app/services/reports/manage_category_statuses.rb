module Reports
  class ManageCategoryStatuses
    attr_reader :category

    def initialize(category)
      @category = category
    end

    def update_statuses!(statuses)
      fail 'statuses is not an array' unless statuses.is_a?(Array)

      initial_used, final_used = false, false

      statuses = statuses.map do |status|
        status.stringify_keys!

        status_params = status.slice(
          'title', 'color', 'initial',
          'final', 'active', 'private',
          'flow_id', 'responsible_group_id',
          'namespace_id'
        )

        if status_params['initial'].present?
          if status_params['initial'] == true && initial_used
            fail 'A report status must only have a single initial status'
          end

          initial_used = true
        end

        if status_params['final'].present?
          final_used = true
        end

        # Convert all attribute values to boolean
        convert_attributes_to_boolean(status_params)

        # Create and/or update report status
        create_and_update_report_status(status_params)
      end

      unless initial_used && final_used
        fail 'A initial and final status must be defined'
      end

      remove_unused_status_categories(statuses)
      find_or_create_status_categories(statuses)
    end

    private

    def remove_unused_status_categories(statuses)
      statuses_ids = statuses.map do |info|
        status = info[0]
        status.id
      end.uniq

      namspaces_ids = statuses.map do |info|
        params = info[1]
        params['namespace_id']
      end.uniq

      category.status_categories.where.not(status: statuses_ids)
                                .where(namespace_id: namspaces_ids)
                                .delete_all
    end

    def find_or_create_status_categories(statuses)
      statuses.map do |info|
        status, params = info[0], info[1]

        status_category = category.status_categories.find_or_create_by(
          status: status, namespace_id: params['namespace_id']
        )

        # Create the many-to-many mapping
        status_category.update(
          initial: params['initial'],
          final: params['final'],
          active: params['active'],
          private: params['private'],
          color: params['color'],
          flow_id: params['flow_id'] || nil,
          responsible_group_id: params['responsible_group_id']
        )

        status_category
      end
    end

    def convert_attributes_to_boolean(params)
      params['initial'] = convert_to_boolean(params['initial'])
      params['final'] = convert_to_boolean(params['final'])
      params['active'] = convert_to_boolean(params['active'])
      params['private'] = convert_to_boolean(params['private'])
    end

    def convert_to_boolean(value)
      if value.is_a?(String)
        value = (value == 'false') ? false : true
      end

      value
    end

    def create_and_update_report_status(status_params)
      report_status = Reports::Status.where('LOWER(title) = LOWER(?)', status_params['title']).first

      report_status ||= Reports::Status.new(
        title: status_params['title']
      )

      if report_status.new_record?
        report_status.color = status_params['color']
        report_status.initial = status_params['initial']
        report_status.final = status_params['final']
        report_status.active = status_params['active']
        report_status.private = status_params['private']
      end

      report_status.save!

      [report_status, status_params]
    end
  end
end

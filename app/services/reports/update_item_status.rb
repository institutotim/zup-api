module Reports
  class UpdateItemStatus
    attr_reader :item, :category, :user
    attr_accessor :case_conductor

    def initialize(item, user = nil)
      @item = item
      @category = item.category
      @user = user
    end

    def set_status(new_status)
      return false if new_status.id == item.status.try(:id)

      validate_status_belonging!(new_status)
      set_status_history_update(new_status)

      relation = get_status_relation(new_status)

      item.status = new_status
      item.resolved_at = Time.now if relation.final?
    end

    def update_status!(new_status)
      return false if new_status.id == item.status.try(:id)

      old_status = item.status
      set_status(new_status)

      item.save!

      Reports::CreateHistoryEntry.new(item, user)
        .create('status', "Foi alterado do status '#{old_status.title}' para '#{new_status.title}'",
                old: old_status.entity(only: [:id, :title]),
                new: new_status.entity(only: [:id, :title])
        )

      Reports::NotifyUser.new(item).notify_status_update!(new_status)

      create_case_for_report!(new_status, case_conductor)
    end

    def create_comment!(message, visibility)
      comment = item.comments.create!(
        author: user,
        message: message,
        visibility: visibility
      )

      Reports::NotifyUser.new(item).notify_new_comment!(comment)
    end

    private

    def set_status_history_update(new_status)
      if new_status.id != item.status.try(:id)
        item.status_history.build(
          previous_status: item.status,
          new_status: new_status
        )
      end
    end

    def validate_status_belonging!(new_status)
      unless get_status_relation(new_status)
        fail "Status doesn't belongs to category"
      end
    end

    def get_status_relation(status)
      category.status_categories.find_by(
        reports_status_id: status.id,
        namespace_id: item.namespace_id
      )
    end

    def create_case_for_report!(new_status, case_conductor)
      relation = get_status_relation(new_status)
      flow = relation.flow
      params = {}

      if flow.present? && item.case.blank?
        last_flow_version = flow.the_version(nil, flow.versions.last.id)
        step = flow.get_new_step_to_case
        params = params.merge(responsible_user_id: case_conductor.id) if case_conductor
        params = params.merge(source_reports_category_id: category.id)
        params = params.merge(namespace_id: item.namespace_id)

        kase = Cases::Create.new(last_flow_version, step, user, params).create!
        item.update(case_id: kase.id, assigned_user: case_conductor)
      end
    end
  end
end

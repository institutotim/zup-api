module Reports
  class AssignToUser
    attr_reader :report, :category, :user

    def initialize(report, user)
      @report = report
      @category = report.category
      @user = user
    end

    def assign!(user_to_assign)
      return if report.assigned_group.blank? || report.assigned_user == user_to_assign
      validate_user_belonging!(user_to_assign)

      old_assigned_user = report.assigned_user
      report.update!(
        assigned_user: user_to_assign
      )

      create_history_entry(old_assigned_user, user_to_assign)
    end

    private

    def validate_user_belonging!(user_to_assign)
      unless user_to_assign.groups.include?(report.assigned_group)
        fail "User doesn't belong to assigned group"
      end
    end

    def create_history_entry(old_assigned_user, user_to_assign)
      changes = {
        new: user_to_assign.entity(only: [:id, :name])
      }

      if old_assigned_user
        changes = changes.merge(
          old: old_assigned_user.entity(only: [:id, :name])
        )
      end

      service = Reports::CreateHistoryEntry.new(report, user)
      service.create('user_assign', "Relato foi associado ao usuário #{user.name}", changes)
    end
  end
end

module Reports
  class ForwardToGroup
    attr_reader :report, :category, :user, :old_group, :perimeter, :setting

    def initialize(report, user = nil)
      @report = report
      @category = report.category
      @setting  = report.setting
      @user = user
      @old_group = report.assigned_group
      @perimeter = load_perimeter
    end

    def forward!(group = nil, message = nil)
      if use_perimeter?
        group = set_group_by_perimeter
      elsif group
        forward(group)

        if setting.comment_required_when_forwarding || message.present?
          create_comment!(message)
        end
      end

      create_history_entry(group) if group
    end

    def forward_without_comment!(group = nil)
      if use_perimeter?
        group = set_group_by_perimeter
      elsif group
        forward(group)
      end

      create_history_entry(group) if group
    end

    private

    def use_perimeter?
      @use_perimeter ||=
        perimeter && (report.perimeter.blank? || report.position_changed?)
    end

    def load_perimeter
      if position = report.position
        if category
          perimeter = category.find_perimeter(report.namespace_id, position.y, position.x)
        end

        perimeter ||= Reports::Perimeter.joins(:group)
                                        .where(namespace_id: report.namespace_id)
                                        .search(position.y, position.x)
                                        .first
      end

      perimeter
    end

    def set_group_by_perimeter
      new_perimeter = perimeter.is_a?(Reports::Perimeter) ? perimeter : perimeter.perimeter

      report.update!(
        assigned_group: perimeter.group,
        perimeter: new_perimeter,
        assigned_user: nil
      )

      perimeter.group
    end

    def validate_group_belonging!(group)
      unless setting.solver_groups.include?(group)
        fail "Group '#{group.name}' isn't a solver"
      end
    end

    # Creates an internal comment
    def create_comment!(message)
      Reports::Comment.create!(
        item: report,
        message: message,
        author: user,
        visibility: Reports::Comment::INTERNAL
      )
    end

    def history_entry(kind, message, options = {})
      Reports::CreateHistoryEntry.new(report, user).create(
        kind, message, options
      )
    end

    def create_history_entry(group)
      if use_perimeter?
        history_entry(
          'perimeter',
          "Este relato está localizado dentro do perímetro '#{perimeter.title}'",
          new: group.entity(only: [:id, :name])
        )
      elsif old_group
        history_entry(
          'forward',
          "Relato foi encaminhado do grupo '#{old_group.name}' para o grupo '#{group.name}'",
          old: old_group.entity(only: [:id, :name]),
          new: group.entity(only: [:id, :name])
        )
      else
        history_entry(
          'forward',
          "Relato foi encaminhado para o grupo '#{group.name}'",
          new: group.entity(only: [:id, :name])
        )
      end
    end

    def forward(group)
      validate_group_belonging!(group)

      report.update!(
        assigned_group: group,
        perimeter: nil,
        assigned_user: nil
      )
    end
  end
end

module Reports
  class CopyToItems
    attr_reader :user, :report, :items

    def initialize(user, report)
      @user = user
      @report = report
      @items = report.grouped_reports.where.not(id: report.id)
    end

    def copy_status(comment = nil, comment_visibility = nil)
      status = report.status

      items.each do |item|
        assign_to_status(item, status, comment, comment_visibility)
      end
    end

    def copy_comment(comment_id)
      comment = report.comments.find(comment_id)
      params  = comment.attributes.slice('author_id', 'visibility', 'message')

      items.each do |item|
        params['reports_item_id'] = item.id

        create_comment(item, params)
      end
    end

    def copy_assigned_user
      user_to_assign = report.assigned_user

      items.each do |item|
        if item.assigned_group != report.assigned_group
          assign_to_group(item, report.assigned_group)
        end

        assign_to_user(item, user_to_assign)
      end
    end

    def copy_assigned_group(comment = nil)
      group_to_assign = report.assigned_group

      items.each do |item|
        assign_to_group(item, group_to_assign, comment)
      end
    end

    private

    def assign_to_status(item, status, comment = nil, comment_visibility = nil)
      service = Reports::UpdateItemStatus.new(item, user)
      service.update_status!(status)

      if comment && comment_visibility
        service.create_comment!(comment, comment_visibility)
      end
    end

    def create_comment(item, params = {})
      service = Reports::CreateComment.new(user, item)
      service.build(params)
      service.save!
    end

    def assign_to_user(item, user_to_assign)
      service = Reports::AssignToUser.new(item, user)
      service.assign!(user_to_assign)
    end

    def assign_to_group(item, group_to_assign, comment = nil)
      service = Reports::ForwardToGroup.new(item, user)
      service.forward!(group_to_assign, comment)
    end
  end
end

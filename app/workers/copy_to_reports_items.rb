class CopyToReportsItems
  include Sidekiq::Worker

  def perform(user_id, report_id, kind, options = {})
    user = User.find(user_id)
    report = Reports::Item.find(report_id)
    options = options.with_indifferent_access

    service = Reports::CopyToItems.new(user, report)

    case kind
    when 'status'  then service.copy_status(options[:comment], options[:visibility])
    when 'user'    then service.copy_assigned_user
    when 'group'   then service.copy_assigned_group(options[:comment])
    when 'comment' then service.copy_comment(options.fetch(:comment_id))
    else fail 'Invalid kind to copy'
    end
  end
end

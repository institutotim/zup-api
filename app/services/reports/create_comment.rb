module Reports
  class CreateComment
    attr_reader :user, :report, :comment

    def initialize(user, report)
      @user = user
      @report = report
    end

    def build(params = {})
      @comment = Reports::Comment.new(params)
    end

    def save!
      comment.save!

      create_entry_history
      notify_user
      send_through_webhook
    end

    private

    def send_through_webhook
      return unless send_through_webhook?

      SendReportThroughWebhook.perform_async(report.uuid, 'update')
    end

    def send_through_webhook?
      !comment.internal? && Webhook.enabled?
    end

    def notify_user
      Reports::NotifyUser.new(report).notify_new_comment!(comment)
    end

    def create_entry_history
      create_history = Reports::CreateHistoryEntry.new(report, user)

      create_history.create(
        'comment',
        "Inseriu um comentário #{translated_visibility}",
        new: comment.entity(only: [:id, :message, :visibility])
      )
    end

    def translated_visibility
      %w(público privado interno)[comment.visibility]
    end
  end
end

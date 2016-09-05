module Reports
  class NotifyUser
    attr_reader :item, :user

    def initialize(item)
      @item = item
      @user = item.user
    end

    def notify_report_creation!
      UserMailer.delay.notify_report_creation(item)
    end

    def notify_status_update!(new_status)
      return false unless should_user_receive_status_notification?(new_status)

      UserMailer.delay.notify_report_status_update(item)

      if user.push_notification_available?
        NotificationPusher.perform_async(user.id,
          "Seu relato mudou para o status '#{new_status.title}'",
          item.id, 'report'
        )
      end
    end

    def notify_new_comment!(comment = nil)
      return false if comment.visibility == Reports::Comment::INTERNAL

      if user.push_notification_available?
        NotificationPusher.perform_async(user.id,
          'Existe um novo comentário da prefeitura para um relato que você realizou',
          item.id, 'report'
        )
      end

      UserMailer.delay.notify_report_comment(item, comment)
    end

    def should_user_receive_status_notification?(status)
      user_permissions.can?(:manage, Reports::Item) \
        || !status.private_for_category?(item.category, item.namespace_id)
    end

    private

    def user_permissions
      @user_permissions ||= UserAbility.for_user(user)
    end
  end
end

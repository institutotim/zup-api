# encoding: utf-8
class AlertMailer < ZupMailer
  RESTRICT_ACTIONS = {
    notify_groups_for_alert: :alerts
  }

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user.send_password_recovery_instructions.subject
  #
  def notify_groups_for_alert(alert)
    @alert = alert
    groups = Group.where(id: alert.groups_alerted)

    users = groups.inject([]) do |users, group|
      users += group.users
    end.uniq

    user_emails = users.map(&:email)

    mail bcc: user_emails, subject: 'Alerta de inventário de item'
  end
end

class Notify
  include Sidekiq::Worker

  def perform(users_ids, notification_params)
    users = User.where(id: users_ids)

    users.each do |user|
      notification = Notification.new(notification_params)
      notification.user = user
      notification.save
    end
  end
end

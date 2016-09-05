namespace :reports_notifications do
  desc 'Generate content for notifications'
  task :generate_content do
    notifications = Reports::Notification.where(content: nil)
                                         .includes(:notification_type)

    puts "Fetching data for #{notifications.count} reports notifications"

    notifications.find_each do |notification|
      notification.send(:set_content)
      notification.save
    end

    puts 'Done!'
  end
end

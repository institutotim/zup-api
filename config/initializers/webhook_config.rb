file_path = File.join(Application.config.root, 'config', 'webhook', 'categories.yml')

if File.exists?(file_path)
  Webhook.load_categories_from_file(file_path)
  Webhook.url = ENV['WEBHOOK_URL']
  Webhook.update_url = ENV['WEBHOOK_UPDATE_URL']
end

SLACK_URL = ENV['SLACK_INCOMING_WEBHOOK_URL'] unless defined? SLACK_URL
SLACK_CHANNEL = ENV['SLACK_NOTIFICATION_CHANNEL'] unless defined? SLACK_URL

class Webhook
  class Base
    def logger
      @logger ||= Yell.new do |l|
        l.adapter :datefile, File.join(Application.config.root, 'log', 'webhook.log'), level: 'gte.info'
      end
    end

    private

    def send_request(url, request_klass, params)
      uri = URI.parse(url)

      request = request_klass.new(uri.path)

      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request, params.to_json)
      end

      yield(response) if block_given?
    end

    def send_slack_hook(message)
      return nil if SLACK_URL.blank?

      Slackhook.send_hook(
        webhook_url: SLACK_URL,
        text: message,
        icon_type: ':exclamation:'
      )
    end
  end
end

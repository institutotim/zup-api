module Reports
  class SendThroughWebhook < Webhook::Base
    attr_reader :report

    def initialize(report)
      @report = report
    end

    def enabled?
      Webhook.enabled? && Webhook.external_category?(report.category)
    end

    def insert!
      return unless enabled?
      send(Webhook.url, Net::HTTP::Post, serialize_report)
    end

    def update!
      return unless enabled?
      send(Webhook.update_url, Net::HTTP::Put, serialize_report(skip_images: true))
    end

    private

    def send(url, request_klass, params)
      send_request(url, request_klass, params) do |response|
        unless response.code == '200'
          fail StandardError.new("Requisição de envio retornou código de status: '#{response.code}'")
        end

        logger.info("Relato ##{report.id} enviado com sucesso! Categoria: ##{report.category.id} (#{report.category.title})")
      end
    rescue => error
      message = "Ocorreu um erro ao enviar o relato ##{report.id} via integração:\n #{error.message}"

      send_slack_hook(message)
      logger.error(message)

      ErrorHandler.capture_exception(error)
      raise error
    end

    def serialize_report(options = {})
      Reports::SerializeToWebhook.new(report).serialize(options)
    rescue Webhook::ExternalCategoryNotFound => e
      # External category not found, let's just log this error for now
      logger.info("Report ##{report.id} isn't for a Webhook category")
    end
  end
end

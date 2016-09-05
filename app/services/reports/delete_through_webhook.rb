module Reports
  class DeleteThroughWebhook < Webhook::Base
    attr_reader :uuid

    def initialize(uuid)
      @uuid = uuid
    end

    def delete!
      return unless Webhook.enabled?

      params = { uuid: uuid }

      send_request(Webhook.update_url, Net::HTTP::Delete, params) do |response|
        unless response.code == '200'
          fail StandardError.new("Requisição de envio retornou código de status: '#{response.code}'")
        end

        logger.info("Relato #{uuid} removido com sucesso!")
      end
    rescue => error
      message = "Ocorreu um erro ao remover o relato #{uuid} via integração:\n #{error.message}"

      send_slack_hook(message)
      logger.error(message)

      ErrorHandler.capture_exception(error)
      raise error
    end
  end
end

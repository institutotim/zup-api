module Reports
  class ConciliateFromWebhook
    attr_reader :report, :hash

    def initialize(report_hash)
      @hash = report_hash.with_indifferent_access
    end

    # Do the conciliation
    def conciliate!
      @report = find_or_create_report_from_hash
      logger.info "Atualizando relato ##{report.id}"
      Reports::UpdateItemFromWebhook.new(report, hash).update!
      logger.info "Relato ##{report.id} foi atualizado com sucesso com os parâmetros: '#{hash.inspect}'"
    rescue => e
      message = "Ocorreu um erro ao conciliar o relato ##{hash[:protocol]} via integração:\n #{e.message} \n #{e.backtrace.first}"
      logger.error(message)
      Raven.capture_exception(e)
    end

    private

    def logger
      Yell.new do |l|
        l.adapter :file,
          File.join(Application.config.root, 'log', 'webhook_conciliation.log'),
          level: 'gte.info'
      end
    end

    def find_or_create_report_from_hash
      if hash[:protocol]
        report = Reports::Item.find_by(protocol: hash[:protocol])
      end

      if !report && hash[:uuid]
        report = Reports::Item.find_by(uuid: hash[:uuid])
      end

      unless report
        report = Reports::CreateItemFromWebhook.new(hash).create!
        logger.info "Relato ##{report.id} foi criado com sucesso"
      end

      report
    end
  end
end

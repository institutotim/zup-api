class ZupMailer < ActionMailer::Base
  add_template_helper(DateHelper)
  add_template_helper(ReportHelper)

  sender_email = ENV['SENDER_EMAIL'] || 'suporte@zeladoriaurbana.com.br'
  sender_name = ENV['SENDER_NAME'] || 'Suporte ZUP'
  default from: "#{sender_name} <#{sender_email}>",
          content_type: 'text/html'

  # Disables email deliver if the
  # option is false
  def self.perform_deliveries
    ENV['DISABLE_EMAIL_SENDING'] != 'true'
  end
end

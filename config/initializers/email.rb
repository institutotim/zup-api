if Application.config.env.development? && !ENV['INTERCEPT_ALL_MAILS_TO'].blank?
  class DevelopmentInterceptor
    def self.delivering_email(message)
      message.to  = "#{message.to.first} <#{ENV["INTERCEPT_ALL_MAILS_TO"]}>"
      message.cc, message.bcc = nil, nil
    end
  end

  ActionMailer::Base.register_interceptor(DevelopmentInterceptor)
end

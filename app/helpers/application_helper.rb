module ApplicationHelper
  def url_for_mailer(path)
    "#{ENV["API_URL"]}/" + path
  end

  def web_url(path)
    "#{ENV["WEB_URL"]}/#/#{path}"
  end

  def public_web_url(path)
    "#{ENV["PUBLIC_WEB_URL"]}/#/#{path}"
  end

  def header_for_mailer
    url_for_mailer(ENV['MAIL_HEADER_IMAGE'] || 'images/header.jpg')
  end

  def greetings_for_email
    ENV['MAIL_CUSTOM_GREETINGS'] || 'Prezado usuário,'
  end

  def greeting_message_for_email
    ENV['MAIL_CUSTOM_GREETING_MESSAGE'] || 'Obrigado por contribuir com a melhoria da cidade.'
  end
end

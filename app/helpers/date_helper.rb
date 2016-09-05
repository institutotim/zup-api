module DateHelper
  def short_date(date)
    I18n.localize(date, format: '%d/%m/%Y')
  end

  def short_date_and_hour(date)
    I18n.localize(date, format: '%d/%m/%Y %H:%M')
  end

  def long_date(date)
    I18n.localize(date, format: 'Enviada em %d de %B de %Y às %Hh%M')
  end
end

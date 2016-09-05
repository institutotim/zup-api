FactoryGirl.define do
  factory :chart do
    association :business_report
    title { 'Gráfico' }
    description { 'Esta é uma descrição' }
    metric { :'total-reports-by-category' }
    chart_type { :pie }
    begin_date Date.new(2015, 6, 1)
    end_date Date.new(2015, 6, 30)
  end
end

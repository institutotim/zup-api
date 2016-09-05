FactoryGirl.define do
  factory :business_report do
    association :user
    title { 'Relatório' }
    summary { 'Este é um exemplo de descrição' }
    params my: { arbitrarily: { complex: ['object'] } }
  end
end

namespace :seed do
  desc 'Create random reports'
  task reports: :environment do
    require 'factory_girl'
    require 'ffaker'
    require 'faker/cpf'

    FactoryGirl.find_definitions

    if ENV['TOTAL'].blank? || ENV['LAT'].blank? || ENV['LNG'].blank?
      fail 'You need to pass LAT, LNG and TOTAL env variables'
    end

    total_for_creation = ENV['TOTAL'].to_i
    latitude = ENV['LAT'].to_f
    longitude = ENV['LNG'].to_f

    categories = Reports::Category.all
    users = User.all

    total_for_creation.times do
      position = RGeo::Geographic.simple_mercator_factory.point(
        *RandomLocationPoint.location(latitude, longitude, 10).reverse
      )
      random_category = categories.sample
      random_status = random_category.statuses.sample
      random_user = users.sample

      FactoryGirl.create(:reports_item,
                         category: random_category,
                         status: random_status,
                         user: random_user,
                         position: position)
    end

    puts 'Done!'
  end
end

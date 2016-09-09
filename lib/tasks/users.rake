namespace :users do
  task randomize_sensitive_data: :environment do
    require 'ffaker'
    require 'faker/cpf'

    puts 'Randomizing user sensitive data...'

    User.find_in_batches do |users|
      users.each do |user|
        user.email = SecureRandom.hex(4) + FFaker::Internet.email
        user.name = FFaker::Name.name
        user.document = Faker::CPF.numeric
        user.postal_code = '04005000'
        user.phone = '11999999999'
        user.save(validate: false)
      end
    end

    puts 'Done!'
  end

  task destroy: :environment do
    fail 'Missing info! You need to inform the user ids on USERS_IDS env var (USERS_IDS=1,3,5,6)' if ENV['USERS_IDS'].blank?

    user_ids = ENV['USERS_IDS'].split(',')

    users = User.find(user_ids)

    puts "You're about to delete the following users: "

    users.each do |user|
      puts "=> ##{user.id} #{user.email}"
    end

    puts 'To confirm the deletion of these users, type DELETE (any other text to cancel):'

    input = STDIN.gets.chomp

    if input == 'DELETE'
      users.each(&:destroy)
      puts 'Users destroyed successfully.'
    else
      puts 'Deletion cancelled'
    end
  end

  task fix_district: :environment do
    puts 'Fixing users district'

    User.where(district: nil).update_all(district: 'Bairro não especificado')

    puts 'Done!'
  end
end

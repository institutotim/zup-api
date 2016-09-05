module Rails
  def self.application
    Struct.new(:config, :paths) do
      def load_seed
        require File.join(Application.config.root, 'application.rb')
        require File.join(Application.config.root, 'db', 'seeds.rb')
      end
    end.new(config, paths)
  end

  def self.config
    require 'erb'
    attrs = OpenStruct.new
    attrs.db_config = ActiveRecord::Base.configurations
    attrs.paths = { 'db' => ['db'] }
    attrs
  end

  def self.paths
    { 'db/migrate' => ["#{root}/db/migrate"] }
  end

  def self.env
    env = ENV['RACK_ENV'] || 'development'
    ActiveSupport::StringInquirer.new(env)
  end

  def self.root
    Application.config.root
  end
end

if ARGV[0] && ARGV[0].start_with?('db:test')
  Bundler.require(:default, :test, :development)
end

ActiveRecord::Tasks::DatabaseTasks.database_configuration = Rails.config.db_config

namespace :g do
  desc 'Generate migration. Specify name in the NAME variable'
  task :migration do
    name = ENV['NAME'] || fail('Specify name: rake g:migration NAME=create_users')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')

    path = "#{Application.config.root}/db/migrate/#{timestamp}_#{name}.rb"
    migration_class = name.split('_').map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF.strip_heredoc
        class #{migration_class} < ActiveRecord::Migration
          def change
          end
        end
      EOF
    end

    puts 'DONE'
    puts path
  end
end

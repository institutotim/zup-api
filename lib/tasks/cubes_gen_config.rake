desc 'Refresh the views used by the BI module'
task cubes_gen_config: :environment do
  File.open(File.join(Application.config.root, 'cubes', 'slicer.ini'), 'w') do |file|
    if ENV['DATABASE_URL']
      url = ENV['DATABASE_URL'].gsub('postgis', 'postgres')
    else
      cf = ActiveRecord::Base.connection_config
      url = "postgres://#{cf[:username]}" + (cf[:password] ? ':' + cf[:password] : '') + "@#{cf[:host]}" + (cf[:port] ? ':' + cf[:port] : '') + "/#{cf[:database]}"
    end
    file << <<-INI
[server]
host = 0.0.0.0
port = 8085
reload = yes
prettyprint = yes
json_record_limit = 8085
allow_cors_origin = *

[store]
type = sql
url = #{url}

[models]
main = ../cubes-model/zup.cubesmodel
    INI
  end
end

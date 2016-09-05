namespace :api do
  desc 'Grape routes'
  task :routes do
    ZUP::API.routes.each do |api|
      method = api.route_method.ljust(10)
      path = api.route_path
      puts "     #{method} #{path}"
    end
  end
end

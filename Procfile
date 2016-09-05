web: bundle exec rake db:clear_memory_cache && DISABLE_MEMORY_CACHE=false /usr/sbin/nginx -c /etc/nginx/nginx.conf
worker: bundle exec sidekiq -r ./application.rb -C ./config/sidekiq.yml
cubes: bundle exec rake cubes_gen_config && god -c ./godfile.rb -D
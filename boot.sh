#!/bin/bash
sed -i "s@passenger_max_pool_size 4@passenger_max_pool_size ${SERVER_WORKERS:-4}@g" /etc/nginx/nginx.conf
sed -i "s@passenger_min_instances 4@passenger_min_instances ${SERVER_WORKERS:-4}@g" /etc/nginx/nginx.conf
bundle exec foreman start -f Procfile
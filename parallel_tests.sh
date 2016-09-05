#!/bin/bash
NUM_CPUS=${NUM_CPUS:-4}
for i in $(seq 0 $(($NUM_CPUS - 1)))
do
    echo "Starting test runner for CPU $(($i + 1))"
    RACK_ENV=test bundle exec rake db:drop db:create db:schema:load CI_NODE_INDEX="$i"
    RACK_ENV=test CI_NODE_TOTAL="$NUM_CPUS" CI_NODE_INDEX="$i" bundle exec rake knapsack:rspec &
done

for job in `jobs -p`
do
    wait $job
done

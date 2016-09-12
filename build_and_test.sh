#!/usr/bin/env bash
# See .gitlab-ci.yml for usage
set -x
CI_BUILD_REF=$TRAVIS_BUILD_ID
CI_BUILD_REF_NAME=$TRAVIS_BRANCH
[ "$CI_BUILD_REF" = "" ] && CI_BUILD_REF=$(( ( RANDOM % 100000 )  + 1 ))
[ "$CI_BUILD_REF_NAME" = "" ] && CI_BUILD_REF_NAME=$(git symbolic-ref --short -q HEAD)
POSTGRES_PASSWORD="zup"
POSTGRES_USER="zup"
SHARED_BUFFERS=128MB
POSTGRES_NAME="postgres$CI_BUILD_REF_NAME$CI_BUILD_REF"
REDIS_NAME="redis$CI_BUILD_REF_NAME$CI_BUILD_REF"
RUBOCOP_NAME="rubocop$CI_BUILD_REF_NAME$CI_BUILD_REF"
API_BRANCH=$CI_BUILD_REF_NAME
NODE_INDEX=$2
CI_NODE_TOTAL=$3

cleanup() {
    kill -9 $BUILD_PID || true
    docker rm -f $(docker ps -q -a --filter "label=build=$CI_BUILD_REF")
}

error_handler() {
    exit_code=$?
    echo "Error on line $1"
    cleanup
    exit $exit_code
}

trap 'error_handler $LINENO' ERR

build() {
    git rev-list --format=%B --max-count=1 HEAD
    git rev-list --format=%B --max-count=1 HEAD > public/commit.txt
    docker run -d --label build=$CI_BUILD_REF --name $REDIS_NAME redis
    docker run --label build=$CI_BUILD_REF -d --name $POSTGRES_NAME -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_DB=$ZUP_DB -e SHARED_BUFFERS=64MB ntxcode/postgresql:9.4
    docker build -t institutotim/zup-api:$CI_BUILD_REF_NAME . &
    BUILD_PID=$!
    wait $BUILD_PID
    docker run --label build=$CI_BUILD_REF --rm --link $REDIS_NAME:redis -e REDIS_URL=redis://redis --link $POSTGRES_NAME:postgres -e DISABLE_MEMORY_CACHE=true -e RACK_ENV=test -e DATABASE_URL=postgis://zup:zup@postgres/default institutotim/zup-api:$CI_BUILD_REF_NAME bundle exec rake db:create db:migrate
}

rubocop() {
    DATABASE_URL="postgis://zup:zup@postgres/default"
    docker run --label build=$CI_BUILD_REF --rm -a stdout -a stderr -e DATABASE_URL=$DATABASE_URL --name $RUBOCOP_NAME institutotim/zup-api:$CI_BUILD_REF_NAME bundle exec rubocop
}

test_node() {
      ZUP_DB="zup$NODE_INDEX"
      docker exec $POSTGRES_NAME /bin/bash -c "PG_PASSWORD=$POSTGRES_PASSWORD createdb --user $POSTGRES_USER -O $POSTGRES_USER -T default $ZUP_DB"
      docker run --link $REDIS_NAME:redis -e REDIS_URL=redis://redis  --label build=$CI_BUILD_REF --rm --link $POSTGRES_NAME:postgres -e RACK_ENV=test -e DATABASE_URL=postgis://zup:zup@postgres/$ZUP_DB -e CI_NODE_TOTAL=$CI_NODE_TOTAL -e CI_NODE_INDEX=$NODE_INDEX institutotim/zup-api:$CI_BUILD_REF_NAME bundle exec rake knapsack:rspec
}

deploy() {
    if [ "$CI_BUILD_REF_NAME" = "unicef" ]; then
        docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
        docker push institutotim/zup-api:$CI_BUILD_REF_NAME
        mkdir -p ~/.ssh
        SSH_DEPLOY_KEY=~/.ssh/id_rsa
        openssl aes-256-cbc -K $encrypted_be5ba593e49d_key -iv $encrypted_be5ba593e49d_iv -in .travis/ntxbot_unicef_deploy.enc -out $SSH_DEPLOY_KEY -d
        chmod 600 $SSH_DEPLOY_KEY
        ssh -i $SSH_DEPLOY_KEY -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $DEPLOY_TARGET "docker pull institutotim/zup-api:$CI_BUILD_REF_NAME; supervisorctl restart zup-api"
        cleanup
    fi
}

case "$1" in
    build) build; exit 0
        ;;
    rubocop) rubocop
        ;;
    test) test_node
        ;;
    deploy) deploy
        ;;
    *)
        build
        rubocop &
        CI_NODE_TOTAL=4
        NODE_INDEX=0
        test_node &
        NODE_INDEX=1
        test_node &
        NODE_INDEX=2
        test_node &
        NODE_INDEX=3
        test_node &
        for job in `jobs -p`
        do
            wait $job
        done
        cleanup
        ;;
esac

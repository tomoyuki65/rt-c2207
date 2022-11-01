#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rt-c2207/tmp/pids/server.pid

# production環境の場合のみJSとCSSをビルド
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails assets:clobber
  bundle exec rails assets:precompile
  bundle exec rails db:migrate
  pg_restore --verbose  --no-acl --no-owner -d rt_c2207_production latest.dump
fi

# サーバー実行(DockerfileのCMDをセット)
exec "$@"

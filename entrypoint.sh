#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rt-c2207/tmp/pids/server.pid

# production環境の場合のみJSとCSSをビルド
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails assets:clobber
  bundle exec rails assets:precompile
  #bundle exec rails db:migrate
  #PGPASSWORD=ylP06SrMY5aoeDaHd8R6wHMAMMulcqJe psql -h dpg-cdge4sta4994kr1roeh0-a.singapore-postgres.render.com -U rt_c2207 rt_c2207_production
  #pg_restore --verbose --no-acl --no-owner -d rt_c2207_production latest.dump
  #bundle exec rails db:drop
  PGPASSWORD=ylP06SrMY5aoeDaHd8R6wHMAMMulcqJe pg_restore --verbose --no-acl --no-owner -h dpg-cdgm2o2en0hj5eagr7f0-a.singapore-postgres.render.com -U rt_c2207 rt_c2207_production_4ory latest.dump
fi

# サーバー実行(DockerfileのCMDをセット)
exec "$@"

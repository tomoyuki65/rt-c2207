#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rt-c2207/tmp/pids/server.pid

# production環境の場合のみJSとCSSをビルド
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails assets:clobber
  bundle exec rails assets:precompile
fi

# production環境の場合のみpumaコマンドでサーバーを起動
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec puma -C config/puma.rb
else
  # DockerfileのCMDをセットして実行
  exec "$@"
fi

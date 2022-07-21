#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rt-c2207/tmp/pids/server.pid

# production環境の場合のみJSとCSSをビルド
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails assets:clobber
  bundle exec rails assets:precompile
fi

# サーバー実行（DockerfileのCMDをセット）
exec "$@"
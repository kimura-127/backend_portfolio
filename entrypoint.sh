#!/bin/bash
set -e

#pidの削除＆ディレクトリの作成
rm -f tmp/pids/server.pid
mkdir -p tmp/sockets
mkdir -p tmp/pids

#DBコンテナが起動するまで待機する処理
until mysqladmin ping -h $DB_HOST -P 3306 -u root --silent; do
  echo "waiting for mysql..."
  sleep 3s
done
echo "success to connect mysql"

#DB作成コマンド
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:migrate:status
bundle exec rails db:seed
#本番環境のみ実行したいが、現状開発環境でも実行されてしまう。
# bundle exec rails assets:precompile RAILS_ENV=production

#Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
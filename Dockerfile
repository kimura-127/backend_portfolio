FROM --platform=linux/x86_64 ruby:3.1.3

#環境変数
ENV APP="/myapp-miguchi"  \
    CONTAINER_ROOT="./" 

#ライブラリのインストール
RUN apt-get update && apt-get install -y \
    nodejs \
    mariadb-client \
    build-essential \
    wget \
    yarn

# Install dependencies
RUN apt-get update && apt-get install -y curl gnupg

# Add the Cloud SDK distribution URI as a package source
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update the package list and install the Cloud SDK
RUN apt-get update && apt-get install -y google-cloud-sdk


#実行するディレクトリの指定
WORKDIR $APP
COPY Gemfile Gemfile.lock $CONTAINER_ROOT
RUN bundle install
#↓懸念点（開発環境ではCOPYをしたくないが、本番環境でする必要がある）
COPY . .

#DB関連の実行
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

#nginxコンテナからrailsコンテナの以下のファイルをマウントすることでソケット通信を可能にする
VOLUME ["/myapp-miguchi/public"]
VOLUME ["/myapp-miguchi/tmp"]

#railsアプリ起動コマンド
CMD ["unicorn", "-p", "3000", "-c", "/myapp-miguchi/config/unicorn.rb", "-E", "$RAILS_ENV"]
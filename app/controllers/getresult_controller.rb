class GetresultController < ApplicationController
  def index
    require "google/cloud/storage"
    require 'httparty'

    # パラムスを取得
    user_id = params[:userid]
    email = params[:email]
    # ユーザー情報を取得
    user = User.find(user_id)
    # ユーザー情報が一致した場合のみ処理を実施
    if user.email == email then
      # Userに紐ついているanalyzesのidをすべて配列で取得
      analyze_videos = user.analyzes.pluck(:id)
      # gcpアクセス時の認証情報
      storage = Google::Cloud::Storage.new(
        credentials: "./test-gcp-intelligence-api-eeddb7d80388.json"
      )

      file_path = []
      # バケット名
      bucket = storage.bucket "endpoint-jab-v1"
      # user_idに適合するバケットのファイルを全て取得
      files = bucket.files prefix: "#{user_id}/"
      # 配列にfilesの情報を挿入
      files.all do |file|
        file_path << file.name
      end

      # 配列を用意
      urls = []
      # 配列それぞれごとにurlを取得
      file_path.each do |path|
        file = bucket.file path
        # 動画データを取得
        url = file.signed_url method: "GET",expires: 300
        if !urls.include?(url)
          # 配列へ変数を代入
          urls << url  
        end
      end

      jsonData = []
      urls.each do |data|
        # データの取得
        res = HTTParty.get(data)
        jsonData << res.parsed_response
      end
      # バックエンドへjsonデータの送信
      render json:{result: jsonData}
    end                      
  end
end

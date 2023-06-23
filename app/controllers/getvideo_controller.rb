class GetvideoController < ApplicationController
  def index
    require "google/cloud/storage"

    # パラムスを取得
    user_id = params[:userid]
    email = params[:email]
    # ユーザー情報を取得
    user = User.find(user_id)
    if user.analyzes.pluck(:id).length >= 1 then
      # ユーザー情報が一致した場合のみ処理を実施
      if user.email == email then
        # Userに紐ついているanalyzesのidをすべて配列で取得
        analyze_videos = user.analyzes.pluck(:id)
        # gcpアクセス時の認証情報
        storage = Google::Cloud::Storage.new(
          credentials: "./test-gcp-intelligence-api-eeddb7d80388.json"
        )

        # 配列を用意
        urls = []

        # 繰り返し処理
        analyze_videos.each do |id|
          # バケット名及びファイル名
          bucket = storage.bucket "source-bakket-jab-v1"
          file = bucket.file "#{user_id}/#{id}"
          # 動画データを取得
          url = file.signed_url method: "GET",expires: 300
          if !urls.include?(url)
            # 配列へ変数を代入
            urls << url  
          end
        end                      
        # バックエンドへ署名付きURLの送信
        render json:{url:urls,status:200}
      end
    else
      puts "なし！"
      render json:{status: 201}
    end
  end

  # def destroy
  #   puts params[:id]
  # end
end

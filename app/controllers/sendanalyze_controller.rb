class SendanalyzeController < ApplicationController

  def create
    # userid・emailの取得
    user_id = params[:userid]
    emailAdores = params[:email]
    userData = User.find(user_id)
    if userData.email == emailAdores
      video_data = userData.analyzes.create()
      video_data_id = video_data.id
      # gcpのコマンド実行用
      require "google/cloud/storage"
      # json形式を取り扱うため
      require 'json'
      # 外部コマンドを実行するため標準搭載のOpen3を利用
      require 'open3'
      # request.jsonに文字列を上書きするため
      require 'fileutils'
      # 分析結果のエンドポイント
      endpoint = "#{user_id}/#{video_data_id}"
      # 動画データを取得
      puts "動画取得開始"
      uploaded_file = params.require(:video)
      if uploaded_file then
        puts "params: success, status: 200, ok!"
      else
        puts "params: failed, status: err, err"
      end
      # 動画データの細分化
      file_data_path = uploaded_file.tempfile.path
      # この文字列をファイルとして扱い、そのファイルをストレージへ送信するため
      jab = {'content': "gs://source-bakket-jab-v1/#{user_id}/#{video_data_id}", 'mimeType': 'video/mp4', 'timeSegmentStart': '0.0s', 'timeSegmentEnd': '160s'}
      jabJsonl = jab.to_json
      # request.jsonのendpointを上書きして出力された結果の名前を変更しその結果を得るため
      request = {"displayName": "jab-display-name",
        "model": "projects/test-gcp-intelligence-api/locations/us-central1/models/7263815816762621952",
        "modelParameters": {
            "confidenceThreshold": 0.1
        },
        "inputConfig": {
            "instancesFormat": "jsonl",
            "gcsSource": {
                "uris": [
                    "gs://source-bakket-jab-v1/jab.jsonl"
                ]
            }
        },
        "outputConfig": {
            "predictionsFormat": "jsonl",
            "gcsDestination": {
                "outputUriPrefix": "gs://endpoint-jab-v1/#{endpoint}"
            }
        }}
      requestjson = request.to_json

      File.write("request.json", requestjson)
      

      # credentialsの情報を元にストレージをインスタンス化
      storage = Google::Cloud::Storage.new(
        credentials: "./test-gcp-intelligence-api-eeddb7d80388.json",
        retries: 10,
        max_elapsed_time: 3000,
        base_interval: 1.5,
        max_interval: 60,
        multiplier: 1.2
      )

      # 変数宣言
      file_name = "#{user_id}/#{video_data_id}"
      bucket_name = "source-bakket-jab-v1"
      bucket = storage.bucket bucket_name

      # # 動画、jsonファイルの送信及び動画の解析処理
      puts "動画送信開始"
      if bucket.create_file  file_data_path, file_name then #ここで動画の送信
        puts "video upload: success, status: 200"
        render json:{status: 200,upload: "success"}
      else
        puts "video upload: failed, status: 500"
        render json:{status: 500,upload: "failed"}
      end
      
        #ここでjsonファイルの送信
      bucket.create_file StringIO.new(jabJsonl), "jab.jsonl"
      
        # 動画,jsonファイルを元に分析開始
        # |------------------------------------------------------------------------------------|
        # |   $(gcloud auth print-access-token)  このコマンドを定期的に実行しアクセストークンを入力    |
        # |------------------------------------------------------------------------------------|
      if Open3.capture3('curl -X POST \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d @request.json \
        "https://us-central1-aiplatform.googleapis.com/v1/projects/test-gcp-intelligence-api/locations/us-central1/batchPredictionJobs"
        ') then
        puts "vertex AI action recognitions deployed!, status:200"
      else
        puts "Failed!"
      end
    end
  end
end

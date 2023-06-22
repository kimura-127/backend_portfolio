class SessionsController < ApplicationController
    def create
      # パラムスからユーザー特定
      user = User.find_by(email: params[:email])
  
      # authenticateメソッドでパスワードの検証
      if user&.authenticate(params[:password])
        
        # トークンのエンコード
        data = { user_id: user.id }
        access_token = JWT.encode({ data: data, exp: Time.current.since(30.seconds).to_i }, 'secret')
        refresh_token = JWT.encode({ data: data, exp: Time.current.since(1.day).to_i }, 'refresh_secret')
  
        # リフレッシュトークン生成
        user.update(refresh_token: refresh_token)
  
        # ここでブラウザにクッキー保存
        cookies[:jwt] = refresh_token
        # アクセストークン送信
        render json: { accessToken: access_token, id: user.id }, status: :ok
      else
        render status: :unauthorized
      end
      
      # リフレッシュする際の処理
      def refresh
        return render status: :unauthorized unless cookies[:jwt]
    
        refresh_token = cookies[:jwt]
        user = User.find_by(refresh_token: refresh_token)
        return render status: :forbidden unless user
    
        payload, = JWT.decode(refresh_token, 'refresh_secret')
        return render status: :forbidden unless payload['data']['user_id'] == user.id
    
        data = { user_id: user.id }
        access_token = JWT.encode({ data: data, exp: Time.current.since(30.seconds).to_i }, 'secret')
    
        render json: { accessToken: access_token } , status: :ok
      end
    end
  end
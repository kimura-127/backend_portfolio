class RegistrationController < ApplicationController
  def create
    # 新規登録後にデータ作成
    email = params[:email]
    password = params[:password]
    User.create(email: email,password: password)
  end
end

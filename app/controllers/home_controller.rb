class HomeController < ApplicationController
  before_action :verify_token

  def index
    render json:{
      status: 200
    }
  end

  private

  def verify_token
    puts ("検証開始")
    auth_header = request.headers["Authorization"]
    return render status: :unauthorized unless auth_header

    token = auth_header.split(" ")[1]

    begin
      payload, = JWT.decode(token, "secret")
    rescue JWT::ExpiredSignature
      return render status: :forbidden
    end
  end
end
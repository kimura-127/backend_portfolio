class RegistrationController < ApplicationController
  def create
    email = params[:email]
    password = params[:password]
    User.create(email: email,password: password)
  end
end

class Api::AuthenticationController < ApplicationController
  def login
    Rails.logger.info "Login attempt for user: #{params[:username]}"
    user = User.find_by(username: params[:username])
    
    if user&.authenticate(params[:password])
      token = JWT.encode({ user_id: user.id, exp: 2.hours.from_now.to_i }, Rails.application.secret_key_base)
      Rails.logger.info "Successful login for user: #{user.id}"
      render json: { token: token }, status: :ok
    else
      Rails.logger.warn "Failed login attempt for username: #{params[:username]}"
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end
end

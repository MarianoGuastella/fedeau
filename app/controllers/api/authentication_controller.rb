class Api::AuthenticationController < ApplicationController
  def login
    sanitized_username = ActionController::Base.helpers.sanitize(params[:username])
    Rails.logger.info "Login attempt for user: #{sanitized_username}"
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      token = JWT.encode({ user_id: user.id, exp: 2.hours.from_now.to_i }, Rails.application.secret_key_base)
      Rails.logger.info "Successful login for user: #{user.id}"
      render json: { token: token }, status: :ok
    else
      Rails.logger.warn "Failed login attempt for username: #{sanitized_username}"
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end
end

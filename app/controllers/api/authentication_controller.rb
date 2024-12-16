class Api::AuthenticationController < ApplicationController
  def login
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      token = JWT.encode(
        { user_id: user.id, exp: 2.hours.from_now.to_i },
        Rails.application.secret_key_base
      )
      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end
end

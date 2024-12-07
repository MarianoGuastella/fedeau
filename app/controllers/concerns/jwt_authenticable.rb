module JwtAuthenticable
  extend ActiveSupport::Concern

  private

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256") rescue nil
    @current_user = User.find(decoded[0]["user_id"]) if decoded
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end

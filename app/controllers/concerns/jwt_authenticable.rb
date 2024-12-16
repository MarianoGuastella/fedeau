module JwtAuthenticable
  extend ActiveSupport::Concern

  private

  def authenticate_user
    header = request.headers["Authorization"]
    Rails.logger.info "Authenticating request with header: #{header.present? ? 'present' : 'missing'}"

    token = header.split(" ").last if header
    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      @current_user = User.find(decoded[0]["user_id"])
    rescue JWT::DecodeError => e
      render json: { error: "Invalid token" }, status: :unauthorized
    rescue JWT::ExpiredSignature
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    end
  end
end

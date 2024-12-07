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
      Rails.logger.info "Successfully authenticated user: #{@current_user.id}"
    rescue StandardError => e
      Rails.logger.warn "Authentication failed: #{e.message}"
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end

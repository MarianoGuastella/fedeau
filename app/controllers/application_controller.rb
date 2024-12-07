class ApplicationController < ActionController::API
  include JwtAuthenticable
end

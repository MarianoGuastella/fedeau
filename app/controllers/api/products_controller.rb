class Api::ProductsController < ApplicationController
  before_action :authenticate_user

  def index
    products = Product.all
    Rails.logger.info "Retrieved #{products.count} products"
    render json: products.as_json(only: [ :id, :name ])
  end

  def create
    sanitized_name = ActionController::Base.helpers.sanitize(params[:name]&.strip)

    if sanitized_name.present?
      Rails.logger.info "Enqueueing product creation with name: #{sanitized_name}"
      ProductCreationJob.perform_later(name: sanitized_name)
      render json: { message: "Product creation queued" }, status: :accepted
    else
      Rails.logger.warn "Attempted to create product without name"
      render json: { error: "Name can't be blank" }, status: :unprocessable_entity
    end
  end
end

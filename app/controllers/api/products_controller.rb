class Api::ProductsController < ApplicationController
  before_action :authenticate_user

  def index
    products = Product.all
    render json: products.as_json(only: [ :id, :name ])
  end

  def create
    product = Product.new(product_params)

    if product.valid?
      ProductCreationJob.perform_later(product_params)
      render json: { message: "Product creation queued" }, status: :accepted
    else
      render json: { error: product.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.permit(:name)
  end
end

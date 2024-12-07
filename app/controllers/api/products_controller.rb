class Api::ProductsController < ApplicationController
  before_action :authenticate_user

  def index
    render json: Product.all.as_json(only: [ :id, :name ])
  end

  def create
    if params[:name].present?
      ProductCreationJob.perform_later(name: params[:name])
      render json: { message: "Product creation queued" }, status: :accepted
    else
      render json: { error: "Name can't be blank" }, status: :unprocessable_entity
    end
  end
end

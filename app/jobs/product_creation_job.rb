class ProductCreationJob < ApplicationJob
  queue_as :default

  def perform(product_params)
    Rails.logger.info "Starting product creation with params: #{product_params}"
    product = Product.create!(product_params)
    Rails.logger.info "Product created successfully: #{product.id}"
  rescue StandardError => e
    Rails.logger.error "Failed to create product: #{e.message}"
    raise e
  end
end

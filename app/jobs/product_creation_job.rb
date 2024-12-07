class ProductCreationJob < ApplicationJob
  queue_as :default

  def perform(product_params)
    Product.create!(product_params)
  end
end

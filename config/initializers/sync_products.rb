require 'net/http'

Rails.application.config.after_initialize do
  begin
    uri = URI('https://23f0013223494503b54c61e8bee1190c.api.mockbin.io/')
    response = Net::HTTP.post(uri, {}.to_json, { 'Content-Type' => 'application/json' })
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      products = data["data"]

      products.each do |product|
        Product.find_or_create_by(id: product['id'], name: product['name'])
      end
      Rails.logger.info "Products synchronized successfully"
    else
      Rails.logger.error "Failed to sync products. Response: #{response.code} #{response.message}"
    end
  rescue StandardError => e
    Rails.logger.error "Error syncing products: #{e.message}"
  end
end

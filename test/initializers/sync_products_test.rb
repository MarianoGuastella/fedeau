require "test_helper"
require "webmock/minitest"

class SyncProductsTest < ActiveSupport::TestCase
  setup do
    
    @api_response = {
      data: [
        { id: 1, name: "Apple" },
        { id: 2, name: "Banana" }
      ]
    }

    stub_request(:post, "https://23f0013223494503b54c61e8bee1190c.api.mockbin.io/")
      .with(
        headers: { 'Content-Type' => 'application/json' },
        body: "{}"
      )
      .to_return(
        status: 200,
        body: @api_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  test "should sync products from external API" do
    assert_difference -> { Product.count }, 2 do
      load Rails.root.join('config/initializers/sync_products.rb')
    end
    
    assert Product.exists?(id: 1, name: "Apple")
    assert Product.exists?(id: 2, name: "Banana")
  end

  test "should not duplicate products on multiple syncs" do
    assert_difference -> { Product.count }, 2 do
      2.times do
        load Rails.root.join('config/initializers/sync_products.rb')
      end
    end
  end

  test "should handle API errors gracefully" do
    stub_request(:post, "https://23f0013223494503b54c61e8bee1190c.api.mockbin.io/")
      .to_return(status: 500)
    
    assert_nothing_raised do
      load Rails.root.join('config/initializers/sync_products.rb')
    end
  end
end 
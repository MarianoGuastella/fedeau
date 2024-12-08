require "test_helper"

class ApiFlowTest < ActionDispatch::IntegrationTest
  def setup
    User.destroy_all
    Product.destroy_all

    @user = User.create!(username: "integration_user", password: "password123")

    @initial_products = [
      { "id" => 1, "name" => "Initial Product 1" },
      { "id" => 2, "name" => "Initial Product 2" }
    ]

    stub_request(:post, "https://23f0013223494503b54c61e8bee1190c.api.mockbin.io/")
      .to_return(
        status: 200,
        body: { data: @initial_products }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    load Rails.root.join("config/initializers/sync_products.rb")
  end

  test "complete API flow" do
    get api_products_url
    assert_response :unauthorized

    post api_authentication_login_url, params: {
      username: "integration_user",
      password: "password123"
    }
    assert_response :success
    token = JSON.parse(@response.body)["token"]
    assert token.present?
    @headers = { "Authorization" => "Bearer #{token}" }

    get api_products_url, headers: @headers
    assert_response :success
    products = JSON.parse(@response.body)
    assert_equal 2, products.length
    assert_equal "Initial Product 1", products.first["name"]
    assert_equal "Initial Product 2", products.second["name"]

    assert_enqueued_with(job: ProductCreationJob) do
      post api_products_url,
           params: { name: "Integration Test Product" },
           headers: @headers
    end
    assert_response :accepted

    perform_enqueued_jobs

    get api_products_url, headers: @headers
    assert_response :success
    products = JSON.parse(@response.body)
    assert_equal 3, products.length
    assert_includes products.map { |p| p["name"] }, "Integration Test Product"

    post api_products_url,
         params: { name: "" },
         headers: @headers
    assert_response :unprocessable_entity
  end

  test "token expiration flow" do
    post api_authentication_login_url, params: {
      username: "integration_user",
      password: "password123"
    }
    token = JSON.parse(@response.body)["token"]
    headers = { "Authorization" => "Bearer #{token}" }

    get api_products_url, headers: headers
    assert_response :success

    travel 3.hours do
      get api_products_url, headers: headers
      assert_response :unauthorized
    end
  end
end

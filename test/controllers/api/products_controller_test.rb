require "test_helper"

class Api::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(username: "test_user", password: "password123")
    @token = JWT.encode({ user_id: @user.id, exp: 2.hours.from_now.to_i }, Rails.application.secret_key_base)
    @headers = { "Authorization" => "Bearer #{@token}" }
    @product = Product.create!(name: "Existing Product")
  end

  test "should get index" do
    get api_products_url, headers: @headers
    assert_response :success
    assert_equal Product.all.as_json(only: [ :id, :name ]), JSON.parse(@response.body)
  end

  test "should not get index without token" do
    get api_products_url
    assert_response :unauthorized
  end

  test "should not get index with invalid token" do
    get api_products_url, headers: { "Authorization" => "Bearer invalid_token" }
    assert_response :unauthorized
  end

  test "should not get index with expired token" do
    expired_token = JWT.encode(
      { user_id: @user.id, exp: 1.day.ago.to_i },
      Rails.application.secret_key_base
    )
    get api_products_url, headers: { "Authorization" => "Bearer #{expired_token}" }
    assert_response :unauthorized
  end

  test "should create product" do
    assert_enqueued_with(job: ProductCreationJob) do
      post api_products_url,
           params: { name: "New Product" },
           headers: @headers
    end
    assert_response :accepted
    assert_equal "Product creation queued", JSON.parse(@response.body)["message"]
  end

  test "should not create product without token" do
    post api_products_url, params: { name: "New Product" }
    assert_response :unauthorized
  end

  test "should not create product without name" do
    post api_products_url,
         params: { name: nil },
         headers: @headers
    assert_response :unprocessable_entity
    assert_equal "Name can't be blank", JSON.parse(@response.body)["error"]
  end

  test "should not create product with empty name" do
    post api_products_url,
         params: { name: "" },
         headers: @headers
    assert_response :unprocessable_entity
    assert_equal "Name can't be blank", JSON.parse(@response.body)["error"]
  end

  test "index should return empty array when no products exist" do
    Product.destroy_all
    get api_products_url, headers: @headers
    assert_response :success
    assert_equal [], JSON.parse(@response.body)
  end
end

require "test_helper"

class Api::AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(username: "test_user", password: "password123")
  end

  test "should login with valid credentials" do
    post api_authentication_login_url, params: {
      username: "test_user",
      password: "password123"
    }
    assert_response :success

    json_response = JSON.parse(@response.body)
    assert json_response["token"].present?

    decoded_token = JWT.decode(
      json_response["token"],
      Rails.application.secret_key_base,
      true,
      algorithm: "HS256"
    )
    assert_equal @user.id, decoded_token[0]["user_id"]
  end

  test "should not login with invalid password" do
    post api_authentication_login_url, params: {
      username: "test_user",
      password: "wrongpassword"
    }
    assert_response :unauthorized
    assert_equal "Invalid username or password", JSON.parse(@response.body)["error"]
  end

  test "should not login with invalid username" do
    post api_authentication_login_url, params: {
      username: "nonexistent",
      password: "password123"
    }
    assert_response :unauthorized
    assert_equal "Invalid username or password", JSON.parse(@response.body)["error"]
  end

  test "should not login without username" do
    post api_authentication_login_url, params: {
      password: "password123"
    }
    assert_response :unauthorized
    assert_equal "Invalid username or password", JSON.parse(@response.body)["error"]
  end

  test "should not login without password" do
    post api_authentication_login_url, params: {
      username: "test_user"
    }
    assert_response :unauthorized
    assert_equal "Invalid username or password", JSON.parse(@response.body)["error"]
  end

  test "token should expire after 3 hours" do
    post api_authentication_login_url, params: {
      username: "test_user",
      password: "password123"
    }
    token = JSON.parse(@response.body)["token"]

    travel 3.hours do
      get api_products_url, headers: { "Authorization" => "Bearer #{token}" }
      assert_response :unauthorized
    end
  end
end

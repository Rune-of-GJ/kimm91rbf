require "test_helper"

class ApiAuthFlowTest < ActionDispatch::IntegrationTest
  test "signup creates user and stores session" do
    assert_difference("User.count", 1) do
      post "/api/auth/signup", params: {
        email: " NewUser@Example.com ",
        password: "password123",
        name: "New User"
      }, as: :json
    end

    assert_response :created
    body = response.parsed_body

    assert_equal "newuser@example.com", body.dig("user", "email")
    assert_equal "New User", body.dig("user", "name")
  end

  test "login rejects invalid credentials" do
    User.create!(email: "student@example.com", password: "password123", name: "Student")

    post "/api/auth/login", params: {
      email: "student@example.com",
      password: "wrong-password"
    }, as: :json

    assert_response :unauthorized
    assert_equal "Invalid email or password", response.parsed_body["error"]
  end

  test "refresh requires authenticated session" do
    post "/api/auth/refresh", as: :json

    assert_response :unauthorized
    assert_equal "Authentication required", response.parsed_body["error"]
  end
end

require "test_helper"

class AdminAccessTest < ActionDispatch::IntegrationTest
  test "admin dashboard redirects to setup when no admin exists" do
    get "/admin/dashboard"

    assert_redirected_to "/admin/setup"
  end

  test "setup creates first admin and signs in" do
    assert_difference("User.where(role: :admin).count", 1) do
      post "/admin/setup", params: {
        user: {
          name: "Admin User",
          email: "admin@example.com",
          password: "password123"
        }
      }
    end

    assert_redirected_to "/admin/dashboard"

    follow_redirect!
    assert_response :success
    assert_match "관리자 대시보드", response.body
  end

  test "student is redirected to access denied when admin exists" do
    User.create!(name: "Admin", email: "admin@example.com", password: "password123", role: :admin)
    User.create!(name: "Student", email: "student@example.com", password: "password123", role: :student)

    post "/api/auth/login", params: {
      email: "student@example.com",
      password: "password123"
    }, as: :json

    get "/admin/dashboard"

    assert_redirected_to "/admin/access-denied"
  end

  test "admin can access dashboard when admin exists" do
    User.create!(name: "Admin", email: "admin@example.com", password: "password123", role: :admin)

    post "/api/auth/login", params: {
      email: "admin@example.com",
      password: "password123"
    }, as: :json

    get "/admin/dashboard"

    assert_response :success
    assert_match "관리자 대시보드", response.body
  end
end

require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin", email: "admin@example.com", password: "password123", role: :admin)
    @student = User.create!(name: "Student", email: "student@example.com", password: "password123", role: :student)
    @instructor = User.create!(name: "Instructor", email: "instructor@example.com", password: "password123", role: :instructor)

    post "/api/auth/login", params: {
      email: "admin@example.com",
      password: "password123"
    }, as: :json
  end

  test "admin can access users page" do
    get "/admin/users"

    assert_response :success
    assert_match "사용자 관리", response.body
  end

  test "admin can update user role" do
    patch "/admin/users/#{@student.id}", params: {
      user: { role: "instructor" }
    }

    assert_redirected_to "/admin/users"
    assert_equal "instructor", @student.reload.role
  end

  test "admin cannot demote last admin" do
    patch "/admin/users/#{@admin.id}", params: {
      user: { role: "student" }
    }

    assert_redirected_to "/admin/users"
    assert_equal "admin", @admin.reload.role
  end

  test "admin can delete another user" do
    assert_difference("User.count", -1) do
      delete "/admin/users/#{@student.id}"
    end

    assert_redirected_to "/admin/users"
  end

  test "admin cannot delete self" do
    assert_no_difference("User.count") do
      delete "/admin/users/#{@admin.id}"
    end

    assert_redirected_to "/admin/users"
  end
end

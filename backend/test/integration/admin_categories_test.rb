require "test_helper"

class AdminCategoriesTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin", email: "admin@example.com", password: "password123", role: :admin)
    @category = Category.create!(name: "Speech", description: "Speech category")

    post "/api/auth/login", params: {
      email: "admin@example.com",
      password: "password123"
    }, as: :json
  end

  test "admin can access categories page" do
    get "/admin/categories"

    assert_response :success
    assert_match "카테고리 관리", response.body
    assert_match "Speech", response.body
  end

  test "admin can create category" do
    assert_difference("Category.count", 1) do
      post "/admin/categories", params: {
        category: {
          name: "Interview",
          description: "Interview category"
        }
      }
    end

    assert_redirected_to "/admin/categories"
  end

  test "admin can update category" do
    patch "/admin/categories/#{@category.id}", params: {
      category: {
        name: "Presentation",
        description: "Updated description"
      }
    }

    assert_redirected_to "/admin/categories"
    assert_equal "Presentation", @category.reload.name
  end

  test "admin can delete empty category" do
    assert_difference("Category.count", -1) do
      delete "/admin/categories/#{@category.id}"
    end

    assert_redirected_to "/admin/categories"
  end

  test "admin cannot delete category with courses" do
    instructor = User.create!(name: "Instructor", email: "instructor@example.com", password: "password123", role: :instructor)
    Course.create!(
      title: "Presentation Flow",
      description: "Course for presentation structure.",
      category: @category,
      instructor: instructor,
      instructor_name: instructor.name
    )

    assert_no_difference("Category.count") do
      delete "/admin/categories/#{@category.id}"
    end

    assert_redirected_to "/admin/categories"
  end
end

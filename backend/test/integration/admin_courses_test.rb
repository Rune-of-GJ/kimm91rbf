require "test_helper"

class AdminCoursesTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin", email: "admin@example.com", password: "password123", role: :admin)
    @instructor = User.create!(name: "Instructor", email: "instructor@example.com", password: "password123", role: :instructor)
    @category = Category.create!(name: "Speech", description: "Speech category")
    @course = Course.create!(
      title: "Presentation Flow",
      description: "Course for presentation structure.",
      category: @category,
      instructor: @instructor,
      instructor_name: @instructor.name
    )
    @course.lectures.create!(
      title: "Opening",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 12
    )

    post "/api/auth/login", params: {
      email: "admin@example.com",
      password: "password123"
    }, as: :json
  end

  test "admin can access courses page" do
    get "/admin/courses"

    assert_response :success
    assert_match "강의 관리", response.body
    assert_match "Presentation Flow", response.body
  end

  test "admin can filter courses by category" do
    other_category = Category.create!(name: "Interview", description: "Interview category")
    Course.create!(
      title: "Interview Practice",
      description: "Course for interview practice.",
      category: other_category,
      instructor: @instructor,
      instructor_name: @instructor.name
    )

    get "/admin/courses", params: { category_id: @category.id }

    assert_response :success
    assert_match "Presentation Flow", response.body
    assert_no_match "Interview Practice", response.body
  end

  test "admin can delete course" do
    assert_difference("Course.count", -1) do
      delete "/admin/courses/#{@course.id}"
    end

    assert_redirected_to "/admin/courses"
  end
end

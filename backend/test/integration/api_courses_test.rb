require "test_helper"

class ApiCoursesTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "발표 스피치", description: "발표 훈련")
    @course = Course.create!(
      title: "스토리텔링 프레젠테이션",
      description: "설명",
      category: @category,
      instructor_name: "기본 강사"
    )
    @lecture = Lecture.create!(
      course: @course,
      title: "1강 오프닝",
      video_url: "https://youtube.com/watch?v=demo",
      order_no: 1,
      duration: 600
    )
    @user = User.create!(email: "student@example.com", password: "password123", name: "Student")
  end

  test "courses index filters by category" do
    other_category = Category.create!(name: "면접 스피치", description: "면접 훈련")
    Course.create!(
      title: "면접 트레이닝",
      description: "설명",
      category: other_category,
      instructor_name: "다른 강사"
    )

    get "/api/courses", params: { category_id: @category.id }, as: :json

    assert_response :success
    assert_equal 1, response.parsed_body.length
    body = response.parsed_body.first
    assert_equal @course.id, body["id"]
    assert_equal @category.name, body["category_name"]
    assert_equal 1, body["lectures_count"]
    assert_equal false, body["enrolled"]
  end

  test "course show returns not found for missing course" do
    get "/api/courses/999999", as: :json

    assert_response :not_found
    assert_equal "Course not found", response.parsed_body["error"]
  end

  test "course show returns availability and curriculum" do
    get "/api/courses/#{@course.id}", as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal @course.id, body["id"]
    assert_equal true, body.dig("availability", "available")
    assert_equal true, body.dig("availability", "enrollment_open")
    assert_equal 1, body["curriculum"].length
  end

  test "enroll is idempotent for existing enrollment" do
    Enrollment.create!(user: @user, course: @course)

    post "/api/auth/login", params: {
      email: @user.email,
      password: "password123"
    }, as: :json

    assert_no_difference("Enrollment.count") do
      post "/api/courses/#{@course.id}/enroll", as: :json
    end

    assert_response :success
    assert_equal @course.id, response.parsed_body["course_id"]
  end

  test "enroll rejects closed enrollment" do
    closed_course = Course.create!(
      title: "마감된 강의",
      description: "설명",
      category: @category,
      instructor_name: "기본 강사",
      enrollment_deadline: Date.yesterday
    )

    post "/api/auth/login", params: {
      email: @user.email,
      password: "password123"
    }, as: :json

    post "/api/courses/#{closed_course.id}/enroll", as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Course is closed for enrollment"
  end
end

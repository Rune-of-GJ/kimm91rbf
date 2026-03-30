require "test_helper"

class ApiProgressTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "student@example.com", password: "password123", name: "Student")
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
  end

  test "progress update requires enrollment" do
    post "/api/auth/login", params: {
      email: @user.email,
      password: "password123"
    }, as: :json

    post "/api/lectures/#{@lecture.id}/progress", params: {
      watched: true
    }, as: :json

    assert_response :forbidden
    assert_equal "Enrollment required", response.parsed_body["error"]
  end

  test "progress update requires watched param" do
    Enrollment.create!(user: @user, course: @course)

    post "/api/auth/login", params: {
      email: @user.email,
      password: "password123"
    }, as: :json

    post "/api/lectures/#{@lecture.id}/progress", as: :json

    assert_response :bad_request
    assert_match(/watched/, response.parsed_body["error"])
  end

  test "lecture endpoints return false for unwatched lectures" do
    Enrollment.create!(user: @user, course: @course)

    post "/api/auth/login", params: {
      email: @user.email,
      password: "password123"
    }, as: :json

    get "/api/courses/#{@course.id}/lectures", as: :json

    assert_response :success
    assert_equal false, response.parsed_body.first["watched"]

    get "/api/lectures/#{@lecture.id}", as: :json

    assert_response :success
    assert_equal false, response.parsed_body["watched"]
  end

  test "enrolled user can update progress and see course progress summary" do
    Enrollment.create!(user: @user, course: @course)

    post "/api/auth/login", params: {
      email: @user.email,
      password: "password123"
    }, as: :json

    post "/api/lectures/#{@lecture.id}/progress", params: {
      watched: true
    }, as: :json

    assert_response :success
    assert_equal true, response.parsed_body["watched"]

    get "/api/users/me/courses", as: :json

    assert_response :success
    body = response.parsed_body.first
    assert_equal @course.id, body["id"]
    assert_equal 1, body["total_lectures"]
    assert_equal 1, body["watched_lectures"]
    assert_equal 100, body["progress_rate"]

    get "/api/users/me/progress", as: :json

    assert_response :success
    progress_body = response.parsed_body.first
    assert_equal @course.id, progress_body["course_id"]
    assert_equal 1, progress_body["lectures"].length
    assert_equal true, progress_body["lectures"].first["watched"]
  end
end

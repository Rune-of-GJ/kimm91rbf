require "test_helper"

class InstructorCoachingTest < ActionDispatch::IntegrationTest
  setup do
    @instructor = User.create!(name: "Instructor", email: "instructor@example.com", password: "password123", role: :instructor)
    @student = User.create!(name: "Student", email: "student@example.com", password: "password123", role: :student)
    @category = Category.create!(name: "Speech", description: "Speech category")
    @course = Course.create!(
      title: "Presentation Delivery",
      description: "Course for delivery practice.",
      category: @category,
      instructor: @instructor,
      instructor_name: @instructor.name
    )
    @lecture = @course.lectures.create!(
      title: "Opening Practice",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 14
    )
    @feedback_request = @student.feedback_requests.create!(
      course: @course,
      lecture: @lecture,
      instructor: @instructor,
      title: "Interview self-introduction rehearsal",
      audio_reference: "intro-01.m4a",
      note: "Please review the first sentence.",
      credit_label: "별도 구매 첨삭 사용",
      used_credits: 1,
      status: :queued
    )
  end

  test "instructor can access coaching queue" do
    login_as(@instructor)

    get "/instructor/coaching/queue"

    assert_response :success
    assert_match "Interview self-introduction rehearsal", response.body
  end

  test "instructor only sees requests assigned to their courses" do
    other_instructor = User.create!(name: "Other Instructor", email: "other@example.com", password: "password123", role: :instructor)
    other_course = Course.create!(
      title: "Other Coach Course",
      description: "Other coach course description.",
      category: @category,
      instructor: other_instructor,
      instructor_name: other_instructor.name
    )
    other_lecture = other_course.lectures.create!(
      title: "Other Lecture",
      video_url: "https://www.youtube.com/watch?v=zzz111",
      order_no: 1,
      duration: 12
    )
    @student.feedback_requests.create!(
      course: other_course,
      lecture: other_lecture,
      instructor: other_instructor,
      title: "Other instructor request",
      audio_reference: "other-request.m4a",
      note: "This should not appear.",
      credit_label: "별도 구매 첨삭 사용",
      used_credits: 1,
      status: :queued
    )

    login_as(@instructor)

    get "/instructor/coaching/queue"

    assert_response :success
    assert_match "Interview self-introduction rehearsal", response.body
    assert_no_match "Other instructor request", response.body
  end

  test "student is redirected from coaching queue" do
    login_as(@student)

    get "/instructor/coaching/queue"

    assert_redirected_to "/instructor/access-denied"
  end

  test "instructor can complete feedback request" do
    login_as(@instructor)

    patch "/instructor/coaching/requests/#{@feedback_request.id}", params: {
      feedback_request: {
        response_timecodes: "00:12 - Please slow down the first sentence.",
        response_summary: "The opening gets much stronger if you relax the pace a little."
      }
    }

    assert_redirected_to "/instructor/coaching/queue"
    @feedback_request.reload
    assert_equal "completed", @feedback_request.status
    assert_equal @instructor.id, @feedback_request.instructor_id
    assert_match "stronger", @feedback_request.response_summary
  end

  private

  def login_as(user)
    post "/api/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json
  end
end

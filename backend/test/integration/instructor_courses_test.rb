require "test_helper"

class InstructorCoursesTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Speaking", description: "Speaking category")
    @instructor = User.create!(name: "Instructor", email: "instructor@example.com", password: "password123", role: :instructor)
    @student = User.create!(name: "Student", email: "student@example.com", password: "password123", role: :student)
  end

  test "instructor can access courses page" do
    login_as(@instructor)

    get "/instructor/courses"

    assert_response :success
    assert_match "내 강의 관리", response.body
  end

  test "student is redirected from instructor pages" do
    login_as(@student)

    get "/instructor/courses"

    assert_redirected_to "/instructor/access-denied"
  end

  test "new course form uses default dates" do
    login_as(@instructor)

    get "/instructor/courses/new"

    assert_response :success
    assert_match Date.current.strftime("%Y-%m-%d"), response.body
    assert_match 10.years.from_now.to_date.strftime("%Y-%m-%d"), response.body
  end

  test "instructor can create course with uploaded thumbnail" do
    login_as(@instructor)
    thumbnail = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/sample-thumbnail.svg"),
      "image/svg+xml"
    )

    assert_difference("Course.count", 1) do
      post "/instructor/courses", params: {
        course: {
          title: "발표 자신감 트랙",
          description: "발표 구조와 전달력을 다듬는 강의입니다.",
          category_id: @category.id,
          thumbnail_file: thumbnail,
          start_date: Date.new(2026, 5, 1),
          end_date: Date.new(2026, 6, 1),
          enrollment_deadline: Date.new(2026, 4, 30)
        }
      }
    end

    assert_redirected_to "/instructor/courses"

    course = Course.order(:created_at).last
    assert_equal @instructor.id, course.instructor_id
    assert_equal @instructor.name, course.instructor_name
    assert_match %r{\A/uploads/course_thumbnails/}, course.thumbnail_url
  end

  test "course create fails with invalid content" do
    login_as(@instructor)

    assert_no_difference("Course.count") do
      post "/instructor/courses", params: {
        course: {
          title: "",
          description: "짧음",
          category_id: "",
          start_date: Date.new(2026, 5, 2),
          end_date: Date.new(2026, 5, 1),
          enrollment_deadline: Date.new(2026, 5, 3)
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "instructor can edit owned course" do
    login_as(@instructor)
    course = create_course_for(@instructor)

    patch "/instructor/courses/#{course.id}", params: {
      course: {
        title: "면접 발표 트랙",
        description: "면접 발표용 흐름과 발성을 집중적으로 수정하는 강의입니다.",
        category_id: @category.id,
        start_date: Date.new(2026, 5, 2),
        end_date: Date.new(2026, 7, 1),
        enrollment_deadline: Date.new(2026, 6, 30)
      }
    }

    assert_redirected_to "/instructor/courses"
    assert_equal "면접 발표 트랙", course.reload.title
  end

  test "instructor can delete owned course" do
    login_as(@instructor)
    course = create_course_for(@instructor)

    assert_difference("Course.count", -1) do
      delete "/instructor/courses/#{course.id}"
    end

    assert_redirected_to "/instructor/courses"
  end

  test "instructor can create lecture for owned course" do
    login_as(@instructor)
    course = create_course_for(@instructor)

    assert_difference("Lecture.count", 1) do
      post "/instructor/courses/#{course.id}/lectures", params: {
        lecture: {
          title: "1강 도입부 설계",
          video_url: "https://www.youtube.com/watch?v=abc123",
          order_no: 1,
          duration: 12
        }
      }
    end

    assert_redirected_to "/instructor/courses"
    assert_equal "1강 도입부 설계", course.lectures.order(:created_at).last.title
  end

  test "instructor can update lecture for owned course" do
    login_as(@instructor)
    course = create_course_for(@instructor)
    lecture = course.lectures.create!(
      title: "1강 초안",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 10
    )

    patch "/instructor/courses/#{course.id}/lectures/#{lecture.id}", params: {
      lecture: {
        title: "1강 도입부 설계",
        video_url: "https://www.youtube.com/watch?v=updated123",
        order_no: 1,
        duration: 14
      }
    }

    assert_redirected_to "/instructor/courses"
    assert_equal "1강 도입부 설계", lecture.reload.title
    assert_equal 14, lecture.duration
  end

  private

  def create_course_for(user)
    user.instructed_courses.create!(
      title: "발표 자신감 트랙",
      description: "발표 구조와 전달력을 다듬는 강의입니다.",
      category: @category,
      instructor_name: user.name,
      start_date: Date.current,
      end_date: 1.month.from_now.to_date,
      enrollment_deadline: 1.month.from_now.to_date
    )
  end

  def login_as(user)
    post "/api/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json
  end
end

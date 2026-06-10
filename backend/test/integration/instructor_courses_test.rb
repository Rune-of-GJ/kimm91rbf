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
    assert_match "새 강의 만들기", response.body
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
    assert_match "섹션 등록", response.body
    assert_match "썸네일 파일", response.body
  end

  test "instructor can create course with uploaded thumbnail and multiple lectures" do
    login_as(@instructor)
    thumbnail = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/sample-thumbnail.svg"),
      "image/svg+xml"
    )

    assert_difference("Course.count", 1) do
      assert_difference("Lecture.count", 2) do
        post "/instructor/courses", params: {
          course: {
            title: "발표 자신감 훈련",
            description: "발표 구조와 전달력을 함께 정리하는 강의입니다.",
            category_id: @category.id,
            thumbnail_file: thumbnail,
            start_date: Date.new(2026, 5, 1),
            end_date: Date.new(2026, 6, 1),
            enrollment_deadline: Date.new(2026, 5, 20),
            lecture_rows_attributes: [
              { title: "1강. 발표 구조 이해하기", video_url: "https://www.youtube.com/watch?v=abc123", duration: 12 },
              { title: "2강. 사례로 흐름 익히기", video_url: "https://www.youtube.com/watch?v=xyz789", duration: 18 }
            ]
          }
        }
      end
    end

    assert_redirected_to "/instructor/courses"

    course = Course.order(:created_at).last
    assert_equal @instructor.id, course.instructor_id
    assert_equal @instructor.name, course.instructor_name
    assert_match %r{\A/uploads/course_thumbnails/}, course.thumbnail_url
    assert_equal ["1강. 발표 구조 이해하기", "2강. 사례로 흐름 익히기"], course.lectures.order(:order_no).pluck(:title)
  end

  test "course create fails without lecture rows" do
    login_as(@instructor)

    assert_no_difference("Course.count") do
      post "/instructor/courses", params: {
        course: {
          title: "발표 기초",
          description: "발표 기초 강의 설명은 열 글자를 넘깁니다.",
          category_id: @category.id,
          start_date: Date.new(2026, 5, 2),
          end_date: Date.new(2026, 5, 30),
          enrollment_deadline: Date.new(2026, 5, 20),
          lecture_rows_attributes: [
            { title: "", video_url: "", duration: "" }
          ]
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "강의편을 1개 이상 추가해 주세요.", response.body
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
          enrollment_deadline: Date.new(2026, 5, 3),
          lecture_rows_attributes: [
            { title: "1강", video_url: "", duration: "10" }
          ]
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
        title: "면접 발표 훈련",
        description: "면접 발표의 흐름과 발성을 집중적으로 수정하는 강의입니다.",
        category_id: @category.id,
        start_date: Date.new(2026, 5, 2),
        end_date: Date.new(2026, 7, 1),
        enrollment_deadline: Date.new(2026, 6, 30)
      }
    }

    assert_redirected_to "/instructor/courses"
    assert_equal "면접 발표 훈련", course.reload.title
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
          title: "1강. 도입부 설계",
          video_url: "https://www.youtube.com/watch?v=abc123&t=721s"
        }
      }
    end

    assert_redirected_to "/instructor/courses/#{course.id}/edit"
    created_lecture = course.lectures.order(:created_at).last
    assert_equal "1강. 도입부 설계", created_lecture.title
    assert_equal "https://www.youtube.com/watch?v=abc123", created_lecture.video_url
    assert_equal 13, created_lecture.duration
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
        title: "1강. 도입부 설계",
        video_url: "https://www.youtube.com/watch?v=updated123&start=840"
      }
    }

    assert_redirected_to "/instructor/courses/#{course.id}/edit"
    assert_equal "1강. 도입부 설계", lecture.reload.title
    assert_equal 14, lecture.duration
    assert_equal "https://www.youtube.com/watch?v=updated123", lecture.video_url
  end

  test "deleting lecture reorders remaining sections" do
    login_as(@instructor)
    course = create_course_for(@instructor)
    first = course.lectures.create!(title: "1강", video_url: "https://www.youtube.com/watch?v=one", order_no: 1, duration: 10)
    second = course.lectures.create!(title: "2강", video_url: "https://www.youtube.com/watch?v=two", order_no: 2, duration: 10)
    third = course.lectures.create!(title: "3강", video_url: "https://www.youtube.com/watch?v=three", order_no: 3, duration: 10)

    assert_difference("Lecture.count", -1) do
      delete "/instructor/courses/#{course.id}/lectures/#{second.id}"
    end

    assert_redirected_to "/instructor/courses/#{course.id}/edit"
    assert_equal [1, 2], course.lectures.order(:order_no).pluck(:order_no)
    assert_equal [first.id, third.id], course.lectures.order(:order_no).pluck(:id)
  end

  private

  def create_course_for(user)
    user.instructed_courses.create!(
      title: "발표 자신감 훈련",
      description: "발표 구조와 전달력을 함께 정리하는 강의입니다.",
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

require "test_helper"

class RehearsalsTest < ActionDispatch::IntegrationTest
  setup do
    MembershipPlan.ensure_defaults!

    @category = Category.create!(name: "Presentation", description: "Presentation category")
    @instructor = User.create!(name: "Coach Kim", email: "coach-kim@example.com", password: "password123", role: :instructor)
    @student = User.create!(name: "Rehearsal Student", email: "rehearsal-student@example.com", password: "password123", role: :student)
    @course = Course.create!(
      title: "면접 스피치 코스",
      description: "면접 스피치 흐름을 정리하는 강의입니다.",
      category: @category,
      instructor: @instructor,
      instructor_name: @instructor.name,
      start_date: Date.current,
      end_date: 1.month.from_now.to_date,
      enrollment_deadline: 1.month.from_now.to_date
    )
    @lecture = @course.lectures.create!(
      title: "1강 자기소개 구조",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 12
    )
    @plan = MembershipPlan.find_by!(slug: "lite")
  end

  test "student can see rehearsals page with remaining count" do
    subscribe_student!
    login_as(@student)

    get "/rehearsals"

    assert_response :success
    assert_match "남은 리허설", response.body
    assert_match @course.title, response.body
  end

  test "student can submit rehearsal when remaining count exists" do
    subscription = subscribe_student!
    login_as(@student)

    assert_difference("RehearsalSubmission.count", 1) do
      post "/rehearsals", params: {
        rehearsal_submission: {
          course_id: @course.id,
          lecture_id: @lecture.id,
          note: "도입부 호흡과 속도를 체크하고 싶습니다."
        }
      }
    end

    assert_redirected_to "/rehearsals"

    submission = @student.rehearsal_submissions.order(:created_at).last
    assert_equal subscription.id, submission.subscription_id
    assert_equal @course.id, submission.course_id
    assert_equal @lecture.id, submission.lecture_id
  end

  test "student can submit rehearsal with uploaded audio file" do
    subscribe_student!
    login_as(@student)

    uploaded_audio = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/sample-audio.m4a"),
      "audio/mp4"
    )

    assert_difference("RehearsalSubmission.count", 1) do
      post "/rehearsals", params: {
        rehearsal_submission: {
          course_id: @course.id,
          lecture_id: @lecture.id,
          audio_file: uploaded_audio,
          note: "업로드 파일과 함께 제출합니다."
        }
      }
    end

    submission = @student.rehearsal_submissions.order(:created_at).last

    assert_redirected_to "/rehearsals"
    assert_match %r{\A업로드 파일: /uploads/rehearsal_audio/rehearsal-\d+-}, submission.note
  end

  test "student can view rehearsal detail page" do
    subscription = subscribe_student!
    login_as(@student)

    submission = @student.rehearsal_submissions.create!(
      subscription: subscription,
      course: @course,
      lecture: @lecture,
      note: "리허설 상세 페이지 확인용 메모",
      submitted_at: Time.current,
      source_label: "manual"
    )

    get "/rehearsals/#{submission.id}"

    assert_response :success
    assert_match "리허설 상세 페이지 확인용 메모", response.body
  end

  test "student without active membership is redirected to plans on submission" do
    login_as(@student)

    assert_no_difference("RehearsalSubmission.count") do
      post "/rehearsals", params: {
        rehearsal_submission: {
          course_id: @course.id,
          lecture_id: @lecture.id,
          note: "멤버십 없이 제출 시도"
        }
      }
    end

    assert_redirected_to "/membership/plans"
  end

  test "student cannot submit when monthly rehearsal limit is exhausted" do
    subscription = subscribe_student!
    login_as(@student)

    @plan.monthly_rehearsal_limit.times do
      @student.rehearsal_submissions.create!(
        subscription: subscription,
        course: @course,
        lecture: @lecture,
        note: "기존 제출",
        submitted_at: Time.current,
        source_label: "manual"
      )
    end

    assert_no_difference("RehearsalSubmission.count") do
      post "/rehearsals", params: {
        rehearsal_submission: {
          course_id: @course.id,
          lecture_id: @lecture.id,
          note: "시도 초과 제출"
        }
      }
    end

    assert_redirected_to "/rehearsals"
  end

  private

  def subscribe_student!
    @student.subscriptions.create!(
      membership_plan: @plan,
      status: :active,
      started_at: Time.current,
      current_period_end: 1.month.from_now
    )
  end

  def login_as(user)
    post "/api/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json
  end
end

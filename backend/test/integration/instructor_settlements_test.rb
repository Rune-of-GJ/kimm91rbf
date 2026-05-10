require "test_helper"

class InstructorSettlementsTest < ActionDispatch::IntegrationTest
  setup do
    MembershipPlan.ensure_defaults!

    @instructor = User.create!(name: "박강사", email: "teacher@example.com", password: "password123", role: :instructor)
    @student = User.create!(name: "수강생", email: "student@example.com", password: "password123", role: :student)
    @category = Category.create!(name: "면접", description: "면접 카테고리")
    @course = Course.create!(
      title: "면접 리허설",
      description: "면접 답변 훈련 코스",
      category: @category,
      instructor: @instructor,
      instructor_name: @instructor.name
    )
    @lecture = @course.lectures.create!(
      title: "자기소개",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 600
    )

    subscription = @student.subscriptions.create!(
      membership_plan: MembershipPlan.find_by!(slug: "coach"),
      status: :active,
      started_at: Time.current.beginning_of_month + 1.day,
      current_period_end: 1.month.from_now
    )

    source_entry = @student.coaching_credit_entries.create!(
      source: subscription,
      credits_amount: 2,
      remaining_credits: 1,
      label: "Coach 포함 첨삭 크레딧"
    )

    Progress.create!(
      user: @student,
      lecture: @lecture,
      watched: true,
      watched_at: Time.current.beginning_of_month + 3.days
    )

    request = @student.feedback_requests.create!(
      title: "면접 톤 첨삭",
      course: @course,
      lecture: @lecture,
      audio_reference: "interview.m4a",
      note: "톤을 봐주세요.",
      credit_label: "Coach 포함 첨삭 크레딧",
      used_credits: 1,
      status: :completed,
      instructor: @instructor,
      response_summary: "톤은 좋지만 문장 끝을 조금 더 또렷하게 마무리하면 좋습니다.",
      response_timecodes: "00:08 문장 끝 호흡이 살짝 약합니다.",
      reviewed_at: Time.current.beginning_of_month + 4.days
    )

    CoachingCreditUsage.create!(
      user: @student,
      feedback_request: request,
      coaching_credit_entry: source_entry,
      credits_amount: 1
    )

    login_as(@instructor)
  end

  test "instructor can view settlement summary" do
    get "/instructor/settlements"

    assert_response :success
    assert_match "내 정산 요약", response.body
    assert_match "예상 지급액", response.body
  end

  test "instructor can view monthly settlement detail" do
    get "/instructor/settlements/month"

    assert_response :success
    assert_match "정산 상세", response.body
    assert_match "첨삭", response.body
  end

  private

  def login_as(user)
    post "/api/auth/login", params: { email: user.email, password: "password123" }, as: :json
  end
end

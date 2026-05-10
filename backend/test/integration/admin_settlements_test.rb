require "test_helper"

class AdminSettlementsTest < ActionDispatch::IntegrationTest
  setup do
    MembershipPlan.ensure_defaults!
    CoachingProduct.ensure_defaults!

    @admin = User.create!(name: "관리자", email: "admin@example.com", password: "password123", role: :admin)
    @instructor = User.create!(name: "김강사", email: "teacher@example.com", password: "password123", role: :instructor)
    @student = User.create!(name: "수강생", email: "student@example.com", password: "password123", role: :student)
    @category = Category.create!(name: "발표", description: "발표 카테고리")
    @course = Course.create!(
      title: "발표 훈련",
      description: "발표 훈련 코스",
      category: @category,
      instructor: @instructor,
      instructor_name: @instructor.name
    )
    @lecture = @course.lectures.create!(
      title: "오프닝",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 600
    )

    subscription = @student.subscriptions.create!(
      membership_plan: MembershipPlan.find_by!(slug: "coach"),
      status: :active,
      started_at: Time.current.beginning_of_month + 2.days,
      current_period_end: 1.month.from_now
    )

    @student.coaching_credit_entries.create!(
      source: subscription,
      credits_amount: 2,
      remaining_credits: 1,
      label: "Coach 포함 첨삭 크레딧"
    )

    Progress.create!(
      user: @student,
      lecture: @lecture,
      watched: true,
      watched_at: Time.current.beginning_of_month + 4.days
    )

    request = @student.feedback_requests.create!(
      title: "자기소개 첨삭",
      course: @course,
      lecture: @lecture,
      audio_reference: "intro.m4a",
      note: "속도를 봐주세요.",
      credit_label: "Coach 포함 첨삭 크레딧",
      used_credits: 1,
      status: :completed,
      instructor: @instructor,
      response_summary: "속도와 호흡을 조금 더 안정적으로 맞추면 좋겠습니다.",
      response_timecodes: "00:12 속도가 조금 빠릅니다.",
      reviewed_at: Time.current.beginning_of_month + 5.days
    )

    source_entry = @student.coaching_credit_entries.find_by!(source: subscription)
    CoachingCreditUsage.create!(
      user: @student,
      feedback_request: request,
      coaching_credit_entry: source_entry,
      credits_amount: 1
    )

    login_as(@admin)
  end

  test "admin can view membership settlement page" do
    get "/admin/settlements/membership"

    assert_response :success
    assert_match "월정액 정산", response.body
    assert_match @instructor.name, response.body
  end

  test "admin can view coaching settlement page" do
    get "/admin/settlements/coaching"

    assert_response :success
    assert_match "첨삭 정산", response.body
    assert_match @instructor.name, response.body
  end

  test "admin can view instructor settlement summary page" do
    get "/admin/settlements/instructors"

    assert_response :success
    assert_match "강사별 정산 요약", response.body
    assert_match @instructor.name, response.body
  end

  private

  def login_as(user)
    post "/api/auth/login", params: { email: user.email, password: "password123" }, as: :json
  end
end

require "test_helper"

class MembershipFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Speaking", description: "Speaking category")
    @course = Course.create!(
      title: "Presentation Confidence",
      description: "Course for presentation structure and delivery.",
      category: @category,
      instructor_name: "Coach Kim"
    )
    @lecture = @course.lectures.create!(
      title: "Opening Structure",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 12
    )
    @user = User.create!(name: "Student", email: "student@example.com", password: "password123", role: :student)

    login_as(@user)
  end

  test "logged in user can view membership pages" do
    get "/membership"
    assert_response :success
    assert_includes response.body, "/membership/plans"

    get "/membership/plans"
    assert_response :success

    get "/membership/checkout"
    assert_response :success
  end

  test "subscribing to coach creates active subscription and included credits" do
    get "/membership/plans"
    coach_plan = MembershipPlan.find_by!(slug: "coach")

    assert_difference("Subscription.count", 1) do
      post "/membership/subscribe", params: { plan_id: coach_plan.id }
    end

    assert_redirected_to "/membership/account"
    assert_equal "coach", @user.reload.active_subscription.membership_plan.slug
    assert_equal 2, @user.coaching_credits_balance

    included_entry = @user.coaching_credit_entries.find_by!(source_type: "Subscription")
    assert_equal 2, included_entry.remaining_credits
  end

  test "active subscription allows lecture access without enrollment" do
    get "/membership/plans"
    pro_plan = MembershipPlan.find_by!(slug: "pro")
    post "/membership/subscribe", params: { plan_id: pro_plan.id }

    get "/lectures/#{@lecture.id}"

    assert_response :success
    assert_match "Opening Structure", response.body
  end

  test "subscribing to a new plan replaces the previous subscription" do
    get "/membership/plans"
    pro_plan = MembershipPlan.find_by!(slug: "pro")
    coach_plan = MembershipPlan.find_by!(slug: "coach")

    post "/membership/subscribe", params: { plan_id: pro_plan.id }
    post "/membership/subscribe", params: { plan_id: coach_plan.id }

    assert_equal "coach", @user.reload.active_subscription.membership_plan.slug
    assert_equal "replaced", @user.subscriptions.order(:created_at).first.status
  end

  test "active subscription can be canceled" do
    get "/membership/plans"
    pro_plan = MembershipPlan.find_by!(slug: "pro")
    post "/membership/subscribe", params: { plan_id: pro_plan.id }

    patch "/membership/cancel"

    assert_redirected_to "/membership/account"
    subscription = @user.subscriptions.order(:created_at).last.reload
    assert_equal "canceled", subscription.status
    assert_nil @user.reload.active_subscription
  end

  private

  def login_as(user)
    post "/api/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json
  end
end

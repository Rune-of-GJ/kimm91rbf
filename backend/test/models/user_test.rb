require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "remaining_rehearsal_count subtracts current month submissions from the active plan limit" do
    MembershipPlan.ensure_defaults!

    user = User.create!(
      name: "Rehearsal Student",
      email: "rehearsal-student@example.com",
      password: "password123",
      role: :student
    )
    plan = MembershipPlan.find_by!(slug: "pro")
    subscription = user.subscriptions.create!(
      membership_plan: plan,
      status: :active,
      started_at: Time.current,
      current_period_end: 1.month.from_now
    )

    2.times do
      user.rehearsal_submissions.create!(
        subscription: subscription,
        submitted_at: Time.current,
        source_label: "manual"
      )
    end

    assert_equal 2, user.current_month_rehearsal_usage
    assert_equal 10, user.remaining_rehearsal_count
  end
end

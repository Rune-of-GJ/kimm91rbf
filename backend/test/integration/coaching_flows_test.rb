require "test_helper"

class CoachingFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @instructor = User.create!(name: "Coach Lee", email: "coach@example.com", password: "password123", role: :instructor)
    @category = Category.create!(name: "Interview", description: "Interview category")
    @course = Course.create!(
      title: "Interview Delivery",
      description: "Course for interview structure and vocal delivery.",
      category: @category,
      instructor: @instructor,
      instructor_name: @instructor.name
    )
    @lecture = @course.lectures.create!(
      title: "Self-introduction Rehearsal",
      video_url: "https://www.youtube.com/watch?v=abc123",
      order_no: 1,
      duration: 15
    )
    @user = User.create!(name: "Student", email: "student@example.com", password: "password123", role: :student)
    @user.enrollments.create!(course: @course)

    login_as(@user)
    MembershipPlan.ensure_defaults!
    CoachingProduct.ensure_defaults!
  end

  test "user can purchase coaching credits" do
    product = CoachingProduct.find_by!(slug: "single-feedback")

    assert_difference("CoachingPurchase.count", 1) do
      post "/coaching/purchases", params: { product_id: product.id }
    end

    assert_redirected_to "/coaching/products"
    assert_equal 1, @user.reload.coaching_credits_balance

    purchased_entry = @user.coaching_credit_entries.find_by!(source_type: "CoachingPurchase")
    assert_equal 1, purchased_entry.remaining_credits
  end

  test "user can create feedback request and consume one credit" do
    product = CoachingProduct.find_by!(slug: "single-feedback")
    post "/coaching/purchases", params: { product_id: product.id }

    assert_difference("FeedbackRequest.count", 1) do
      post "/coaching/request", params: {
        feedback_request: {
          title: "Interview self-introduction rehearsal",
          course_id: @course.id,
          lecture_id: @lecture.id,
          audio_reference: "intro-rehearsal-01.m4a",
          note: "Please focus on pacing in the first 20 seconds."
        }
      }
    end

    request = @user.reload.feedback_requests.order(:created_at).last
    purchased_entry = @user.coaching_credit_entries.find_by!(source_type: "CoachingPurchase")

    assert_redirected_to "/coaching/requests"
    assert_equal 0, @user.coaching_credits_balance
    assert_equal "Interview self-introduction rehearsal", request.title
    assert_equal @instructor.id, request.instructor_id
    assert_equal purchased_entry.id, request.applied_credit_entry_id
    assert_equal "membership_first", request.credit_source_preference
    assert_equal 0, purchased_entry.reload.remaining_credits
    assert_equal 1, CoachingCreditUsage.where(feedback_request: request, coaching_credit_entry: purchased_entry).count
  end

  test "user can create feedback request with uploaded audio file" do
    product = CoachingProduct.find_by!(slug: "single-feedback")
    post "/coaching/purchases", params: { product_id: product.id }

    uploaded_audio = Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/sample-audio.m4a"),
      "audio/mp4"
    )

    assert_difference("FeedbackRequest.count", 1) do
      post "/coaching/request", params: {
        feedback_request: {
          title: "Uploaded audio rehearsal",
          course_id: @course.id,
          lecture_id: @lecture.id,
          audio_file: uploaded_audio,
          audio_reference: "",
          note: "Please review the uploaded recording."
        }
      }
    end

    request = @user.reload.feedback_requests.order(:created_at).last

    assert_redirected_to "/coaching/requests"
    assert_match %r{\A/uploads/feedback_audio/feedback-\d+-}, request.audio_reference
  end

  test "default allocation consumes included membership credits before purchased credits" do
    coach_plan = MembershipPlan.find_by!(slug: "coach")
    product = CoachingProduct.find_by!(slug: "single-feedback")

    post "/membership/subscribe", params: { plan_id: coach_plan.id }
    post "/coaching/purchases", params: { product_id: product.id }

    subscription_entry = @user.coaching_credit_entries.find_by!(source_type: "Subscription")
    purchase_entry = @user.coaching_credit_entries.find_by!(source_type: "CoachingPurchase")

    post "/coaching/request", params: {
      feedback_request: {
        title: "Coach plan priority check",
        course_id: @course.id,
        lecture_id: @lecture.id,
        audio_reference: "coach-priority-01.m4a",
        note: "Check which source gets consumed first."
      }
    }

    request = @user.reload.feedback_requests.order(:created_at).last

    assert_equal "membership_first", request.credit_source_preference
    assert_equal @instructor.id, request.instructor_id
    assert_equal subscription_entry.id, request.applied_credit_entry_id
    assert_equal 1, subscription_entry.reload.remaining_credits
    assert_equal 1, purchase_entry.reload.remaining_credits
    assert_equal 2, @user.coaching_credits_balance
  end

  test "feedback request requires course with assigned instructor" do
    other_category = Category.create!(name: "Voice", description: "Voice category")
    course_without_instructor = Course.create!(
      title: "Voice Warmup",
      description: "Warmup course without instructor assignment.",
      category: other_category,
      instructor_name: "Unassigned"
    )
    lecture = course_without_instructor.lectures.create!(
      title: "Warmup Basics",
      video_url: "https://www.youtube.com/watch?v=def456",
      order_no: 1,
      duration: 10
    )
    @user.enrollments.create!(course: course_without_instructor)

    product = CoachingProduct.find_by!(slug: "single-feedback")
    post "/coaching/purchases", params: { product_id: product.id }

    assert_no_difference("FeedbackRequest.count") do
      post "/coaching/request", params: {
        feedback_request: {
          title: "No instructor request",
          course_id: course_without_instructor.id,
          lecture_id: lecture.id,
          audio_reference: "voice-warmup.m4a",
          note: "Please review."
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "담당 강사가 연결된 강의만 첨삭 요청할 수 있습니다.", response.body
  end

  test "user can view feedback request detail page" do
    product = CoachingProduct.find_by!(slug: "single-feedback")
    post "/coaching/purchases", params: { product_id: product.id }
    post "/coaching/request", params: {
      feedback_request: {
        title: "Detail page rehearsal",
        course_id: @course.id,
        lecture_id: @lecture.id,
        audio_reference: "detail-page.m4a",
        note: "Please review the detail page request."
      }
    }

    request = @user.reload.feedback_requests.order(:created_at).last

    get "/coaching/requests/#{request.id}"

    assert_response :success
    assert_match "Detail page rehearsal", response.body
  end

  private

  def login_as(user)
    post "/api/auth/login", params: {
      email: user.email,
      password: "password123"
    }, as: :json
  end
end

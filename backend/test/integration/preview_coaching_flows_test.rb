require "test_helper"

class PreviewCoachingFlowsTest < ActionDispatch::IntegrationTest
  test "student coaching products preview loads" do
    get "/preview/student/coaching/products"
    assert_response :success
  end

  test "student coaching request preview loads" do
    get "/preview/student/coaching/request"
    assert_response :success
  end

  test "student coaching requests preview loads" do
    get "/preview/student/coaching/requests"
    assert_response :success
  end

  test "student coaching request complete preview loads" do
    get "/preview/student/coaching/request-complete"
    assert_response :success
  end

  test "instructor coaching queue preview loads" do
    get "/preview/instructor/coaching/queue"
    assert_response :success
  end

  test "instructor coaching review preview loads" do
    get "/preview/instructor/coaching/review"
    assert_response :success
  end
end

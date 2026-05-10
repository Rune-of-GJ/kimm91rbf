require "test_helper"

class PreviewSettlementsTest < ActionDispatch::IntegrationTest
  test "admin membership settlement preview loads" do
    get "/preview/admin/settlements/membership"
    assert_response :success
  end

  test "admin coaching settlement preview loads" do
    get "/preview/admin/settlements/coaching"
    assert_response :success
  end

  test "admin instructor settlement preview loads" do
    get "/preview/admin/settlements/instructors"
    assert_response :success
  end

  test "instructor settlement summary preview loads" do
    get "/preview/instructor/settlements"
    assert_response :success
  end

  test "instructor monthly settlement preview loads" do
    get "/preview/instructor/settlements/month"
    assert_response :success
  end
end

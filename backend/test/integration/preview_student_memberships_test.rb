require "test_helper"

class PreviewStudentMembershipsTest < ActionDispatch::IntegrationTest
  test "membership landing preview loads" do
    get "/preview/student/membership"
    assert_response :success
  end

  test "membership plans preview loads" do
    get "/preview/student/membership/plans"
    assert_response :success
  end

  test "membership checkout preview loads" do
    get "/preview/student/membership/checkout"
    assert_response :success
  end

  test "membership account preview loads" do
    get "/preview/student/membership/account"
    assert_response :success
  end
end

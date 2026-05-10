require "test_helper"

class PreviewStudentCommerceTest < ActionDispatch::IntegrationTest
  setup do
    category = Category.create!(name: "Speaking", description: "Preview category")
    instructor = User.create!(name: "Instructor", email: "preview-instructor@example.com", password: "password123", role: :instructor)

    2.times do |index|
      Course.create!(
        title: "Preview paid course #{index + 1}",
        description: "Preview paid course description #{index + 1}",
        category: category,
        instructor: instructor,
        instructor_name: instructor.name
      )
    end
  end

  test "paid course preview loads" do
    get "/preview/student/paid-course"
    assert_response :success
  end

  test "cart preview loads" do
    get "/preview/student/cart"
    assert_response :success
  end

  test "checkout preview loads" do
    get "/preview/student/checkout"
    assert_response :success
  end

  test "order complete preview loads" do
    get "/preview/student/order-complete"
    assert_response :success
  end
end

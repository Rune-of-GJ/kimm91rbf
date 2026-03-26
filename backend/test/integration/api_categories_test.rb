require "test_helper"

class ApiCategoriesTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "발표 스피치", description: "발표 훈련")
    Course.create!(
      title: "스토리텔링 프레젠테이션",
      description: "설명",
      category: @category,
      instructor_name: "기본 강사"
    )
  end

  test "categories index returns category list" do
    get "/api/categories", as: :json

    assert_response :success
    body = response.parsed_body.first
    assert_equal @category.name, body["name"]
    assert_equal @category.description, body["description"]
  end

  test "category show returns courses count" do
    get "/api/categories/#{@category.id}", as: :json

    assert_response :success
    assert_equal 1, response.parsed_body["courses_count"]
  end
end

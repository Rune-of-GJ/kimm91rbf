module Api
  module V1
    class CategoriesController < BaseController
      def index
        categories = Category.order(:name)
        render json: categories.as_json(only: %i[id name description])
      end

      def show
        category = Category.find(params[:id])
        render json: category.as_json(only: %i[id name description]).merge(courses_count: category.courses.count)
      end
    end
  end
end

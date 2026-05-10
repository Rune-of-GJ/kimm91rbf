module Preview
  module Instructor
    class CoursesController < ApplicationController
      def new
        @preview_categories = Category.order(:name)
        @preview_instructor = User.where(role: :instructor).order(created_at: :desc).first
        @preview_instructor_counts = {
          courses: Course.where(instructor_id: @preview_instructor&.id).count,
          categories: Category.count
        }
      end
    end
  end
end

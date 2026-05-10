module Admin
  class CoursesController < BaseController
    before_action :set_course, only: :destroy

    def index
      @course_counts = {
        total: Course.count,
        categories: Category.count,
        instructors: User.where(role: :instructor).count,
        lectures: Lecture.count
      }
      @categories = Category.order(:name)
      @category_filter = params[:category_id].presence
      @query = params[:q].to_s.strip

      scope = Course.includes(:category, :lectures, :instructor).order(created_at: :desc)
      scope = scope.where(category_id: @category_filter) if @category_filter.present?

      if @query.present?
        pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
        scope = scope.where(
          "courses.title LIKE :pattern OR courses.instructor_name LIKE :pattern OR courses.description LIKE :pattern",
          pattern: pattern
        )
      end

      @courses = scope
    end

    def destroy
      course_title = @course.title
      @course.destroy!

      redirect_to admin_courses_path(category_id: params[:category_id], q: params[:q]),
        notice: "#{course_title} 강의를 삭제했습니다."
    end

    private

    def set_course
      @course = Course.find(params[:id])
    end
  end
end

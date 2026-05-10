module Instructor
  module Courses
    class LecturesController < BaseController
      before_action :set_course
      before_action :set_lecture, only: [:edit, :update]

      def new
        @lecture = @course.lectures.new(order_no: next_order_no)
        @instructor_counts = build_counts(current_user.instructed_courses)
      end

      def create
        @lecture = @course.lectures.new(lecture_params)
        @instructor_counts = build_counts(current_user.instructed_courses)

        if @lecture.save
          redirect_to instructor_courses_path, notice: "강의편 추가에 성공했습니다!"
        else
          flash.now[:alert] = @lecture.errors.full_messages.join(", ")
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @instructor_counts = build_counts(current_user.instructed_courses)
      end

      def update
        @instructor_counts = build_counts(current_user.instructed_courses)

        if @lecture.update(lecture_params)
          redirect_to instructor_courses_path, notice: "강의편 수정에 성공했습니다!"
        else
          flash.now[:alert] = @lecture.errors.full_messages.join(", ")
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def set_course
        @course = current_user.instructed_courses.includes(:lectures).find(params[:course_id])
      end

      def set_lecture
        @lecture = @course.lectures.find(params[:id])
      end

      def lecture_params
        params.require(:lecture).permit(:title, :video_url, :order_no, :duration)
      end

      def next_order_no
        (@course.lectures.maximum(:order_no) || 0) + 1
      end

      def build_counts(scope)
        {
          courses: scope.count,
          categories: Category.count,
          upcoming: scope.where("start_date >= ?", Date.current).count
        }
      end
    end
  end
end

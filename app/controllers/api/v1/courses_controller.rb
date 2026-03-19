module Api
  module V1
    class CoursesController < BaseController
      before_action :require_login!, only: [:enroll]

      def index
        courses = Course.includes(:category).order(created_at: :desc)
        courses = courses.where(category_id: params[:category_id]) if params[:category_id].present?

        render json: courses.map { |course| course_payload(course) }
      end

      def show
        course = Course.includes(:lectures).find(params[:id])

        render json: course_payload(course).merge(
          curriculum: course.lectures.map { |lecture| lecture_payload(lecture) },
          availability: {
            start_date: course.start_date,
            end_date: course.end_date,
            enrollment_deadline: course.enrollment_deadline
          }
        )
      end

      def enroll
        course = Course.find(params[:id])
        enrollment = Enrollment.find_or_initialize_by(user: current_user, course: course)

        if enrollment.persisted? || enrollment.save
          render json: {
            id: enrollment.id,
            user_id: enrollment.user_id,
            course_id: enrollment.course_id,
            created_at: enrollment.created_at
          }, status: :created
        else
          render json: { errors: enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def course_payload(course)
        {
          id: course.id,
          title: course.title,
          description: course.description,
          instructor_id: course.instructor_id,
          instructor_name: course.instructor_name,
          thumbnail_url: course.thumbnail_url,
          category_id: course.category_id
        }
      end

      def lecture_payload(lecture)
        {
          id: lecture.id,
          title: lecture.title,
          video_url: lecture.video_url,
          order_no: lecture.order_no,
          duration: lecture.duration
        }
      end
    end
  end
end

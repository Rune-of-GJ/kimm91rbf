module Api
  module V1
    class CoursesController < BaseController
      before_action :require_login!, only: [:enroll]

      def index
        courses = Course.includes(:category, :lectures).order(created_at: :desc)
        courses = courses.where(category_id: params[:category_id]) if params[:category_id].present?

        render json: courses.map { |course| course_payload(course) }
      end

      def show
        course = Course.includes(:category, :lectures).find(params[:id])

        render json: course_payload(course).merge(
          curriculum: course.lectures.map { |lecture| lecture_payload(lecture) },
          availability: {
            start_date: course.start_date,
            end_date: course.end_date,
            enrollment_deadline: course.enrollment_deadline,
            max_access_days: course.max_access_days,
            available: course.available_on?,
            enrollment_open: course.enrollment_open?
          }
        )
      end

      def enroll
        course = Course.find(params[:id])
        enrollment = Enrollment.find_by(user: current_user, course: course)

        if enrollment
          respond_to do |format|
            format.html { redirect_to root_path, notice: "#{course.title} 강의에 이미 수강 신청되었습니다." }
            format.json { render json: enrollment_payload(enrollment), status: :ok }
          end
          return
        end

        enrollment = Enrollment.new(user: current_user, course: course)

        if enrollment.save
          respond_to do |format|
            format.html { redirect_to root_path, notice: "#{course.title} 강의 수강 신청이 완료되었습니다." }
            format.json { render json: enrollment_payload(enrollment), status: :created }
          end
        else
          respond_to do |format|
            format.html { redirect_to root_path, alert: "수강 신청에 실패했습니다: #{enrollment.errors.full_messages.join(', ')}" }
            format.json { render json: { errors: enrollment.errors.full_messages }, status: :unprocessable_entity }
          end
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
          category_id: course.category_id,
          category_name: course.category.name,
          lectures_count: course.lectures.size,
          enrolled: current_user.present? ? enrolled_in_course?(course) : false
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

      def enrollment_payload(enrollment)
        {
          id: enrollment.id,
          user_id: enrollment.user_id,
          course_id: enrollment.course_id,
          created_at: enrollment.created_at
        }
      end
    end
  end
end

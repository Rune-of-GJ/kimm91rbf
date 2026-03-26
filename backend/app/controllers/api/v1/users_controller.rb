module Api
  module V1
    class UsersController < BaseController
      before_action :require_login!

      def me_courses
        courses = current_user.enrolled_courses.includes(:category, :lectures).order(created_at: :desc)

        render json: courses.map { |course| me_course_payload(course) }
      end

      def me_progress
        courses = current_user.enrolled_courses.includes(:lectures).order(created_at: :desc)

        render json: courses.map { |course| me_progress_payload(course) }
      end

      private

      def me_course_payload(course)
        stats = course_progress_stats(course)

        {
          id: course.id,
          title: course.title,
          description: course.description,
          category_id: course.category_id,
          instructor_name: course.instructor_name,
          thumbnail_url: course.thumbnail_url,
          total_lectures: stats[:total_lectures],
          watched_lectures: stats[:watched_lectures],
          progress_rate: stats[:progress_rate]
        }
      end

      def me_progress_payload(course)
        stats = course_progress_stats(course)
        lecture_progress = current_user.progresses.where(lecture_id: course.lecture_ids).index_by(&:lecture_id)

        {
          course_id: course.id,
          course_title: course.title,
          total_lectures: stats[:total_lectures],
          watched_lectures: stats[:watched_lectures],
          progress_rate: stats[:progress_rate],
          lectures: course.lectures.map do |lecture|
            progress = lecture_progress[lecture.id]

            {
              lecture_id: lecture.id,
              lecture_title: lecture.title,
              order_no: lecture.order_no,
              watched: progress&.watched || false,
              watched_at: progress&.watched_at
            }
          end
        }
      end

      def course_progress_stats(course)
        total_lectures = course.lectures.size
        watched_count = current_user.progresses.where(lecture_id: course.lecture_ids, watched: true).count
        progress_rate = total_lectures.zero? ? 0 : ((watched_count.to_f / total_lectures) * 100).round

        {
          total_lectures: total_lectures,
          watched_lectures: watched_count,
          progress_rate: progress_rate
        }
      end
    end
  end
end

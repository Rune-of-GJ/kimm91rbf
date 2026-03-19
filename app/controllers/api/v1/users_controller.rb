module Api
  module V1
    class UsersController < BaseController
      before_action :require_login!

      def me_courses
        courses = current_user.enrolled_courses.includes(:category).order(created_at: :desc)

        render json: courses.map { |course|
          {
            id: course.id,
            title: course.title,
            description: course.description,
            category_id: course.category_id,
            instructor_name: course.instructor_name,
            thumbnail_url: course.thumbnail_url
          }
        }
      end

      def me_progress
        progress = current_user.progresses.includes(lecture: :course).order(updated_at: :desc)

        render json: progress.map { |item|
          {
            id: item.id,
            lecture_id: item.lecture_id,
            lecture_title: item.lecture.title,
            course_id: item.lecture.course_id,
            course_title: item.lecture.course.title,
            watched: item.watched,
            watched_at: item.watched_at
          }
        }
      end
    end
  end
end

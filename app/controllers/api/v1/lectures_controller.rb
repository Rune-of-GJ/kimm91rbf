module Api
  module V1
    class LecturesController < BaseController
      before_action :require_login!, only: [:progress]

      def index
        lectures = Lecture.where(course_id: params[:course_id]).order(:order_no)
        render json: lectures.as_json(only: %i[id course_id title video_url order_no duration])
      end

      def show
        lecture = Lecture.find(params[:id])
        render json: lecture.as_json(only: %i[id course_id title video_url order_no duration])
      end

      def progress
        lecture = Lecture.find(params[:id])
        progress = Progress.find_or_initialize_by(user: current_user, lecture: lecture)
        watched = ActiveModel::Type::Boolean.new.cast(params[:watched])

        progress.watched = watched
        progress.watched_at = watched ? Time.current : nil

        if progress.save
          render json: {
            id: progress.id,
            user_id: progress.user_id,
            lecture_id: progress.lecture_id,
            watched: progress.watched,
            watched_at: progress.watched_at
          }, status: :ok
        else
          render json: { errors: progress.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end

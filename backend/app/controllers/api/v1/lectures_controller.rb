module Api
  module V1
    class LecturesController < BaseController
      before_action :require_login!, only: [:progress]

      def index
        lectures = Lecture.where(course_id: params[:course_id]).order(:order_no)
        render json: lectures.map { |lecture| lecture_payload(lecture) }
      end

      def show
        lecture = Lecture.find(params[:id])
        render json: lecture_payload(lecture)
      end

      def progress
        lecture = Lecture.includes(:course).find(params[:id])

        unless enrolled_in_course?(lecture.course)
          return render json: { error: "Enrollment required" }, status: :forbidden
        end

        watched = ActiveModel::Type::Boolean.new.cast(params.require(:watched))
        progress = Progress.find_or_initialize_by(user: current_user, lecture: lecture)
        progress.watched = watched
        progress.watched_at = watched ? Time.current : nil

        if progress.save
          render json: progress_payload(progress), status: :ok
        else
          render json: { errors: progress.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def lecture_payload(lecture)
        watched = if current_user.present?
          current_user.progresses.find_by(lecture_id: lecture.id)&.watched || false
        else
          false
        end

        {
          id: lecture.id,
          course_id: lecture.course_id,
          title: lecture.title,
          video_url: lecture.video_url,
          order_no: lecture.order_no,
          duration: lecture.duration,
          watched: watched
        }
      end

      def progress_payload(progress)
        {
          id: progress.id,
          user_id: progress.user_id,
          lecture_id: progress.lecture_id,
          watched: progress.watched,
          watched_at: progress.watched_at
        }
      end
    end
  end
end

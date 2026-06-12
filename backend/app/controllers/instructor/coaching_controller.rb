module Instructor
  class CoachingController < BaseController
    before_action :set_queue_scope
    before_action :set_feedback_request, only: [:show, :update]

    def index
      @feedback_requests = @queue_scope.order(updated_at: :desc, created_at: :desc)
      @instructor_counts = build_counts(current_user.instructed_courses)
      @coaching_counts = {
        queued: @queue_scope.queued.count,
        reviewing: @queue_scope.reviewing.count,
        completed: @queue_scope.completed.count
      }
    end

    def show
      @instructor_counts = build_counts(current_user.instructed_courses)
      @coaching_counts = {
        queued: @queue_scope.queued.count,
        reviewing: @queue_scope.reviewing.count,
        completed: @queue_scope.completed.count
      }
      if @feedback_request.queued?
        @feedback_request.update!(status: :reviewing, instructor: current_user)
      end
    end

    def update
      @instructor_counts = build_counts(current_user.instructed_courses)
      @coaching_counts = {
        queued: @queue_scope.queued.count,
        reviewing: @queue_scope.reviewing.count,
        completed: @queue_scope.completed.count
      }

      @feedback_request.assign_attributes(feedback_request_params)
      @feedback_request.instructor = current_user
      @feedback_request.status = :completed
      @feedback_request.reviewed_at = Time.current

      if @feedback_request.save
        UserMailer.feedback_completed(@feedback_request).deliver_later
        DiscordNotifier.notify(
          title: "첨삭 완료",
          description: "**#{current_user.name}** 강사가 **#{@feedback_request.user.name}** 님의 첨삭을 완료했습니다.\n제목: #{@feedback_request.title}",
          color: :success
        )
        redirect_to instructor_coaching_queue_path, notice: "첨삭 완료 처리에 성공했습니다!"
      else
        flash.now[:alert] = @feedback_request.errors.full_messages.join(", ")
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_queue_scope
      @queue_scope = FeedbackRequest
        .includes(:user, :course, :lecture, :instructor)
        .left_outer_joins(:course)
        .where(
          "feedback_requests.instructor_id = :instructor_id OR (feedback_requests.instructor_id IS NULL AND courses.instructor_id = :instructor_id)",
          instructor_id: current_user.id
        )
        .distinct
    end

    def set_feedback_request
      @feedback_request = @queue_scope.find(params[:id])
    end

    def feedback_request_params
      params.require(:feedback_request).permit(:response_timecodes, :response_summary)
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

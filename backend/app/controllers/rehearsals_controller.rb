class RehearsalsController < ApplicationController
  before_action :require_login_for_html!
  before_action :ensure_membership_catalog!
  before_action :set_rehearsal_context

  def index
    @rehearsal_submission = current_user.rehearsal_submissions.new(
      course_id: @available_courses.first&.id
    )
    @available_lectures = build_available_lectures
  end

  def show
    @rehearsal_submission = current_user.rehearsal_submissions.includes(:course, :lecture, :subscription).find(params[:id])
  end

  def create
    unless @active_subscription
      redirect_to membership_plans_path, alert: "리허설 제출은 활성 멤버십이 필요합니다."
      return
    end

    if current_user.remaining_rehearsal_count == 0
      redirect_to rehearsals_path, alert: "이번 달 리허설 제출 한도를 모두 사용했습니다."
      return
    end

    @rehearsal_submission = current_user.rehearsal_submissions.new(rehearsal_submission_params)
    attach_audio_upload(@rehearsal_submission, params.dig(:rehearsal_submission, :audio_file))
    @rehearsal_submission.subscription = @active_subscription
    @rehearsal_submission.submitted_at = Time.current
    @rehearsal_submission.source_label = "manual"
    @available_lectures = build_available_lectures

    if @rehearsal_submission.save
      redirect_to rehearsals_path, notice: "리허설 제출에 성공했습니다!"
    else
      flash.now[:alert] = @rehearsal_submission.errors.full_messages.join(", ")
      render :index, status: :unprocessable_entity
    end
  end

  private

  def ensure_membership_catalog!
    MembershipPlan.ensure_defaults!
  end

  def set_rehearsal_context
    @active_subscription = current_user.active_subscription
    @current_plan = current_user.current_membership_plan
    @available_courses = current_user.learning_courses.includes(:lectures)
    @recent_rehearsals = current_user.rehearsal_submissions.includes(:course, :lecture).order(submitted_at: :desc).limit(8)
    @rehearsal_usage = current_user.current_month_rehearsal_usage
    @remaining_rehearsal_count = current_user.remaining_rehearsal_count
  end

  def build_available_lectures
    Lecture.where(course_id: @available_courses.map(&:id)).order(:course_id, :order_no)
  end

  def rehearsal_submission_params
    params.require(:rehearsal_submission).permit(:course_id, :lecture_id, :note)
  end

  def attach_audio_upload(rehearsal_submission, upload)
    return if upload.blank?

    uploads_dir = Rails.root.join("public", "uploads", "rehearsal_audio")
    FileUtils.mkdir_p(uploads_dir)

    allowed = %w[.mp3 .wav .m4a .webm .ogg .aac .flac]
    extension = File.extname(upload.original_filename.to_s).downcase
    extension = ".bin" unless allowed.include?(extension)
    filename = "rehearsal-#{current_user.id}-#{SecureRandom.hex(8)}#{extension}"
    absolute_path = uploads_dir.join(filename)

    File.binwrite(absolute_path, upload.read)
    reference_line = "업로드 파일: /uploads/rehearsal_audio/#{filename}"
    rehearsal_submission.note = [reference_line, rehearsal_submission.note.presence].compact.join("\n")
  end
end

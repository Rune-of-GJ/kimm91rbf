class CoachingController < ApplicationController
  before_action :require_login_for_html!
  before_action :ensure_commerce_catalog!
  before_action :set_shared_context

  def products
    @coaching_products = CoachingProduct.active.ordered
  end

  def purchase
    product = CoachingProduct.active.find(params.require(:product_id))

    ActiveRecord::Base.transaction do
      purchase = current_user.coaching_purchases.create!(
        coaching_product: product,
        status: :completed,
        paid_amount: product.price,
        credits_amount: product.credits_amount
      )

      current_user.coaching_credit_entries.create!(
        source: purchase,
        credits_amount: product.credits_amount,
        remaining_credits: product.credits_amount,
        label: "#{product.name} 구매 크레딧"
      )
    end

    redirect_to coaching_products_path, notice: "#{product.name} 구매에 성공했습니다!"
  end

  def requests
    @feedback_requests = current_user.feedback_requests.includes(:course, :lecture).order(created_at: :desc)
  end

  def show_request
    @feedback_request = current_user.feedback_requests.includes(:course, :lecture, :instructor).find(params[:id])
  end

  def new_request
    @feedback_request = current_user.feedback_requests.new
    @available_courses = current_user.learning_courses
    @available_lectures = Lecture.where(course_id: @available_courses.map(&:id)).order(:course_id, :order_no)
  end

  def create_request
    if current_user.coaching_credits_balance <= 0
      redirect_to coaching_products_path, alert: "사용 가능한 첨삭 크레딧이 없습니다."
      return
    end

    @feedback_request = current_user.feedback_requests.new(feedback_request_params)
    attach_audio_upload(@feedback_request, params.dig(:feedback_request, :audio_file))
    @feedback_request.status = :queued
    @feedback_request.used_credits = 1
    @feedback_request.instructor = @feedback_request.course&.instructor
    @available_courses = current_user.learning_courses
    @available_lectures = Lecture.where(course_id: @available_courses.map(&:id)).order(:course_id, :order_no)

    if @feedback_request.course.blank?
      @feedback_request.errors.add(:course_id, "대상 강의를 선택해주세요.")
      render :new_request, status: :unprocessable_entity
      return
    end

    if @feedback_request.instructor.blank?
      @feedback_request.errors.add(:course_id, "담당 강사가 연결된 강의만 첨삭 요청할 수 있습니다.")
      render :new_request, status: :unprocessable_entity
      return
    end

    allocator = CoachingCreditAllocator.new(
      user: current_user,
      preference: @feedback_request.credit_source_preference
    )

    begin
      allocation = allocator.build_allocation(amount: @feedback_request.used_credits)
      @feedback_request.credit_label = allocation.label
      @feedback_request.credit_source_preference = allocation.preference
      @feedback_request.applied_credit_entry = allocation.primary_entry
    rescue CoachingCreditAllocator::InsufficientCreditsError
      redirect_to coaching_products_path, alert: "사용 가능한 첨삭 크레딧이 없습니다."
      return
    end

    if @feedback_request.valid?
      ActiveRecord::Base.transaction do
        @feedback_request.save!
        allocation.commit!(feedback_request: @feedback_request)
        current_user.coaching_credit_entries.create!(
          source: @feedback_request,
          credits_amount: -1,
          remaining_credits: 0,
          label: @feedback_request.credit_label
        )
      end

      redirect_to coaching_requests_path, notice: "첨삭 요청에 성공했습니다!"
    else
      render :new_request, status: :unprocessable_entity
    end
  end

  private

  def ensure_commerce_catalog!
    MembershipPlan.ensure_defaults!
    CoachingProduct.ensure_defaults!
  end

  def set_shared_context
    @active_subscription = current_user.active_subscription
    @coaching_balance = current_user.coaching_credits_balance
  end

  def feedback_request_params
    params.require(:feedback_request).permit(
      :title,
      :course_id,
      :lecture_id,
      :audio_reference,
      :note,
      :credit_source_preference
    )
  end

  def attach_audio_upload(feedback_request, upload)
    return if upload.blank?

    uploads_dir = Rails.root.join("public", "uploads", "feedback_audio")
    FileUtils.mkdir_p(uploads_dir)

    extension = File.extname(upload.original_filename.to_s).presence || ".bin"
    filename = "feedback-#{current_user.id}-#{SecureRandom.hex(8)}#{extension}"
    absolute_path = uploads_dir.join(filename)

    File.binwrite(absolute_path, upload.read)
    feedback_request.audio_reference = "/uploads/feedback_audio/#{filename}"
  end
end

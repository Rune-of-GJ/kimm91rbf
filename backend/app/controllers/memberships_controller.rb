class MembershipsController < ApplicationController
  before_action :require_login_for_html!
  before_action :ensure_membership_catalog!
  before_action :set_membership_context

  def show; end

  def plans; end

  def checkout
    requested_slug = params[:plan].presence || @active_subscription&.membership_plan&.slug || "pro"
    @selected_plan = @membership_plans.find { |plan| plan.slug == requested_slug } || @membership_plans.first
    @next_billing_date = 1.month.from_now.to_date
  end

  def account; end

  def subscribe
    plan = MembershipPlan.active.find(params.require(:plan_id))

    ActiveRecord::Base.transaction do
      current_user.subscriptions.active.update_all(
        status: Subscription.statuses[:replaced],
        canceled_at: Time.current,
        updated_at: Time.current
      )

      subscription = current_user.subscriptions.create!(
        membership_plan: plan,
        status: :active,
        started_at: Time.current,
        current_period_end: 1.month.from_now
      )

      UserMailer.membership_subscribed(subscription).deliver_later

      next unless plan.monthly_coaching_credits.positive?

      current_user.coaching_credit_entries.create!(
        source: subscription,
        credits_amount: plan.monthly_coaching_credits,
        remaining_credits: plan.monthly_coaching_credits,
        label: "#{plan.name} 포함 첨삭 크레딧"
      )
    end

    redirect_to membership_account_path, notice: "#{plan.name} 멤버십 가입에 성공했습니다!"
  end

  def payment_success
    plan = MembershipPlan.active.find(params.require(:plan_id))
    payment_key = params.require(:paymentKey)
    order_id = params.require(:orderId)
    amount = params.require(:amount).to_i

    unless amount == plan.monthly_price.to_i
      redirect_to membership_payment_fail_path(message: "결제 금액이 올바르지 않습니다.")
      return
    end

    unless confirm_toss_payment(payment_key, order_id, amount)
      redirect_to membership_payment_fail_path(message: "결제 검증에 실패했습니다.")
      return
    end

    ActiveRecord::Base.transaction do
      current_user.subscriptions.active.update_all(
        status: Subscription.statuses[:replaced],
        canceled_at: Time.current,
        updated_at: Time.current
      )

      subscription = current_user.subscriptions.create!(
        membership_plan: plan,
        status: :active,
        started_at: Time.current,
        current_period_end: 1.month.from_now
      )

      UserMailer.membership_subscribed(subscription).deliver_later

      next unless plan.monthly_coaching_credits.positive?

      current_user.coaching_credit_entries.create!(
        source: subscription,
        credits_amount: plan.monthly_coaching_credits,
        remaining_credits: plan.monthly_coaching_credits,
        label: "#{plan.name} 포함 첨삭 크레딧"
      )
    end

    redirect_to membership_account_path, notice: "#{plan.name} 멤버십 가입이 완료되었습니다!"
  rescue ActiveRecord::RecordNotFound
    redirect_to membership_plans_path, alert: "플랜 정보를 찾을 수 없습니다."
  rescue => e
    Rails.logger.error "Membership payment_success error: #{e.message}"
    redirect_to membership_payment_fail_path(message: "서버 오류가 발생했습니다.")
  end

  def payment_fail
    @message = params[:message] || params[:code] || "결제가 취소되었습니다."
  end

  def cancel
    subscription = current_user.active_subscription

    unless subscription
      redirect_to membership_account_path, alert: "현재 활성 멤버십이 없습니다."
      return
    end

    ActiveRecord::Base.transaction do
      subscription.update!(
        status: :canceled,
        canceled_at: Time.current,
        current_period_end: Time.current
      )

      current_user.coaching_credit_entries
        .where(source: subscription)
        .available_for_consumption
        .update_all(expires_at: Time.current)
    end

    redirect_to membership_account_path, notice: "#{subscription.membership_plan.name} 멤버십을 해지했습니다."
  end

  private

  def ensure_membership_catalog!
    MembershipPlan.ensure_defaults!
  end

  def set_membership_context
    @membership_plans = MembershipPlan.active.ordered.to_a
    @active_subscription = current_user.active_subscription
    @selected_plan = @membership_plans.find(&:featured?) || @membership_plans.first
    @recent_feedback_requests = current_user.feedback_requests.order(created_at: :desc).limit(3)
    @recent_subscriptions = current_user.subscriptions.includes(:membership_plan).order(created_at: :desc).limit(5)

    credit_entries = current_user.coaching_credit_entries.available_for_consumption
    @included_coaching_credits = credit_entries.where(source_type: "Subscription").sum(:remaining_credits)
    @purchased_coaching_credits = credit_entries.where(source_type: "CoachingPurchase").sum(:remaining_credits)
    @total_coaching_credits = @included_coaching_credits + @purchased_coaching_credits
  end
end

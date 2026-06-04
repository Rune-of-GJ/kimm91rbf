class SettlementReportBuilder
  PG_FEE_RATE = 0.033
  TAX_RATE = 0.1
  INSTRUCTOR_POOL_RATE = 0.6
  COACHING_PLATFORM_FEE_RATE = 0.1
  MINIMUM_WATCH_MINUTES = 60
  MINIMUM_PAYOUT_AMOUNT = 10_000
  FALLBACK_INCLUDED_COACHING_UNIT_PRICE = 29_000

  attr_reader :month

  def initialize(month: Date.current)
    @month = month.to_date.beginning_of_month
  end

  def membership_report
    @membership_report ||= begin
      gross_revenue = subscription_scope.sum { |subscription| subscription.membership_plan.monthly_price }
      refund_amount = 0
      pg_fee_amount = (gross_revenue * PG_FEE_RATE).round
      tax_amount = (gross_revenue * TAX_RATE).round
      other_deduction_amount = 0
      settlement_revenue = [gross_revenue - refund_amount - pg_fee_amount - tax_amount - other_deduction_amount, 0].max
      instructor_pool_amount = (settlement_revenue * INSTRUCTOR_POOL_RATE).round

      contribution_rows = build_watch_contribution_rows(instructor_pool_amount)

      {
        month_label: month.strftime("%Y.%m"),
        subscription_revenue: gross_revenue,
        refund_amount: refund_amount,
        pg_fee_amount: pg_fee_amount,
        tax_amount: tax_amount,
        other_deduction_amount: other_deduction_amount,
        settlement_revenue: settlement_revenue,
        instructor_pool_rate: INSTRUCTOR_POOL_RATE,
        instructor_pool_amount: instructor_pool_amount,
        total_valid_watch_minutes: contribution_rows.sum { |row| row[:watch_minutes] },
        minimum_watch_minutes: MINIMUM_WATCH_MINUTES,
        minimum_payout_amount: MINIMUM_PAYOUT_AMOUNT,
        rows: contribution_rows
      }
    end
  end

  def coaching_report
    @coaching_report ||= begin
      rows = build_coaching_rows
      gross = rows.sum { |row| row[:gross] }
      platform_fee = rows.sum { |row| row[:platform_fee] }
      instructor_total = rows.sum { |row| row[:payout] }

      {
        month_label: month.strftime("%Y.%m"),
        gross: gross,
        platform_fee: platform_fee,
        instructor_total: instructor_total,
        completed_requests: rows.sum { |row| row[:completed_requests] },
        rows: rows
      }
    end
  end

  def instructor_summary_rows
    membership_rows = membership_report[:rows].index_by { |row| row[:instructor_id] }
    coaching_rows = coaching_report[:rows].index_by { |row| row[:instructor_id] }

    instructor_ids = (membership_rows.keys + coaching_rows.keys).compact.uniq

    User.where(id: instructor_ids).order(:name).map do |instructor|
      membership_row = membership_rows[instructor.id]
      coaching_row = coaching_rows[instructor.id]
      membership_payout = membership_row&.dig(:payout).to_i
      coaching_payout = coaching_row&.dig(:payout).to_i
      hold_amount = membership_row&.dig(:hold_amount).to_i
      final_payout = membership_payout + coaching_payout

      {
        instructor_id: instructor.id,
        instructor: instructor.name,
        membership_payout: membership_payout,
        coaching_payout: coaching_payout,
        hold_amount: hold_amount,
        final_payout: final_payout,
        status: hold_amount.positive? ? "이월" : "지급 대상"
      }
    end
  end

  def instructor_report(instructor)
    membership_row = membership_report[:rows].find { |row| row[:instructor_id] == instructor.id }
    coaching_row = coaching_report[:rows].find { |row| row[:instructor_id] == instructor.id }

    {
      month_label: month.strftime("%Y.%m"),
      membership: membership_row || empty_membership_row(instructor),
      coaching: coaching_row || empty_coaching_row(instructor),
      final_payout: membership_row&.dig(:payout).to_i + coaching_row&.dig(:payout).to_i
    }
  end

  private

  def month_range
    @month_range ||= month.beginning_of_month..month.end_of_month.end_of_day
  end

  def subscription_scope
    @subscription_scope ||= Subscription.includes(:membership_plan, :user).where(started_at: month_range)
  end

  def watch_progress_scope
    @watch_progress_scope ||= Progress.includes(:user, lecture: { course: :instructor })
      .where(watched: true, watched_at: month_range)
  end

  def completed_feedback_scope
    @completed_feedback_scope ||= FeedbackRequest.includes(
      :instructor,
      coaching_credit_usages: :coaching_credit_entry
    ).completed.where(reviewed_at: month_range)
  end

  def build_watch_contribution_rows(instructor_pool_amount)
    contribution = Hash.new { |hash, key| hash[key] = { instructor: nil, instructor_id: nil, watch_seconds: 0 } }

    watch_progress_scope.each do |progress|
      next unless paid_watch?(progress)

      course = progress.lecture.course
      instructor = course.instructor
      next if instructor.blank?

      row = contribution[instructor.id]
      row[:instructor] = instructor.name
      row[:instructor_id] = instructor.id
      row[:watch_seconds] += normalized_watch_seconds(progress.lecture)
    end

    total_watch_seconds = contribution.values.sum { |row| row[:watch_seconds] }

    contribution.values.sort_by { |row| [-row[:watch_seconds], row[:instructor].to_s] }.map do |row|
      share = total_watch_seconds.positive? ? row[:watch_seconds].to_f / total_watch_seconds : 0.0
      watch_minutes = (row[:watch_seconds] / 60.0).round
      raw_payout = (instructor_pool_amount * share).round
      eligible = watch_minutes >= MINIMUM_WATCH_MINUTES && raw_payout >= MINIMUM_PAYOUT_AMOUNT

      row.merge(
        share: share,
        watch_minutes: watch_minutes,
        payout: eligible ? raw_payout : 0,
        hold_amount: eligible ? 0 : raw_payout,
        eligible: eligible
      )
    end
  end

  def build_coaching_rows
    grouped = Hash.new do |hash, key|
      hash[key] = {
        instructor: nil,
        instructor_id: nil,
        completed_requests: 0,
        gross: 0,
        platform_fee: 0,
        payout: 0
      }
    end

    completed_feedback_scope.each do |request|
      next if request.instructor.blank?

      gross = coaching_gross_amount(request)
      platform_fee = (gross * COACHING_PLATFORM_FEE_RATE).round
      payout = gross - platform_fee

      row = grouped[request.instructor_id]
      row[:instructor] = request.instructor.name
      row[:instructor_id] = request.instructor_id
      row[:completed_requests] += 1
      row[:gross] += gross
      row[:platform_fee] += platform_fee
      row[:payout] += payout
    end

    grouped.values.sort_by { |row| [-row[:payout], row[:instructor].to_s] }
  end

  def paid_watch?(progress)
    watched_at = progress.watched_at || progress.updated_at

    progress.user.subscriptions.any? do |subscription|
      subscription.started_at <= watched_at &&
        (subscription.canceled_at.blank? || subscription.canceled_at >= watched_at)
    end
  end

  def normalized_watch_seconds(lecture)
    duration = lecture.duration.to_i
    return 0 if duration <= 0

    duration >= 60 ? duration : duration * 60
  end

  def coaching_gross_amount(request)
    usages = request.coaching_credit_usages.includes(:coaching_credit_entry)
    return request.used_credits * unit_price_for_entry(request.applied_credit_entry) if usages.empty?

    usages.sum do |usage|
      usage.credits_amount * unit_price_for_entry(usage.coaching_credit_entry)
    end
  end

  def unit_price_for_entry(entry)
    return 0 if entry.blank?

    source = entry.source

    case source
    when CoachingPurchase
      credits = source.credits_amount.to_i
      return 0 if credits <= 0

      (source.paid_amount.to_f / credits).round
    when Subscription
      unit_price = source.membership_plan.included_coaching_unit_price
      unit_price.positive? ? unit_price : FALLBACK_INCLUDED_COACHING_UNIT_PRICE
    else
      0
    end
  end

  def empty_membership_row(instructor)
    {
      instructor_id: instructor.id,
      instructor: instructor.name,
      share: 0.0,
      watch_seconds: 0,
      watch_minutes: 0,
      payout: 0,
      hold_amount: 0,
      eligible: false
    }
  end

  def empty_coaching_row(instructor)
    {
      instructor_id: instructor.id,
      instructor: instructor.name,
      completed_requests: 0,
      gross: 0,
      platform_fee: 0,
      payout: 0
    }
  end
end

class SettlementReportJob < ApplicationJob
  queue_as :default

  def perform
    week_start = 1.week.ago.beginning_of_day
    week_end = Time.current

    new_subs = Subscription.where(created_at: week_start..week_end).count
    new_purchases = CoachingPurchase.where(created_at: week_start..week_end).count
    completed_requests = FeedbackRequest.completed.where(reviewed_at: week_start..week_end).count

    Rails.logger.info(
      "[SettlementReport] #{week_start.strftime('%Y-%m-%d')} ~ #{week_end.strftime('%Y-%m-%d')} | " \
      "신규 멤버십: #{new_subs}, 크레딧 구매: #{new_purchases}, 첨삭 완료: #{completed_requests}"
    )
  end
end

class ExpireSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    expired = Subscription.active.where("current_period_end < ?", Time.current)
    count = 0
    expired.find_each do |sub|
      sub.update!(status: :expired)
      Rails.logger.info "Expired subscription ##{sub.id} for user ##{sub.user_id}"
      count += 1
    end
    DiscordNotifier.notify(
      title: "구독 만료 배치 완료",
      description: "만료 처리된 구독: **#{count}건**",
      color: count > 0 ? :warning : :info
    )
  end
end

class ExpireSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    expired = Subscription.active.where("current_period_end < ?", Time.current)
    expired.find_each do |sub|
      sub.update!(status: :expired)
      Rails.logger.info "Expired subscription ##{sub.id} for user ##{sub.user_id}"
    end
  end
end

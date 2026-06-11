class UserMailer < ApplicationMailer
  def membership_subscribed(subscription)
    @subscription = subscription
    @user = subscription.user
    @plan = subscription.membership_plan
    mail(to: @user.email, subject: "[SpeakFlow] #{@plan.name} 멤버십 가입을 환영합니다!")
  end

  def coaching_credits_purchased(purchase)
    @purchase = purchase
    @user = purchase.user
    @product = purchase.coaching_product
    mail(to: @user.email, subject: "[SpeakFlow] 첨삭 크레딧 구매가 완료되었습니다.")
  end

  def feedback_request_received(feedback_request)
    @feedback_request = feedback_request
    @instructor = feedback_request.instructor
    @student = feedback_request.user
    mail(to: @instructor.email, subject: "[SpeakFlow] 새 첨삭 요청이 도착했습니다.")
  end

  def feedback_completed(feedback_request)
    @feedback_request = feedback_request
    @student = feedback_request.user
    @instructor = feedback_request.instructor
    mail(to: @student.email, subject: "[SpeakFlow] 첨삭이 완료되었습니다.")
  end
end

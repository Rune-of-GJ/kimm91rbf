MembershipPlan.ensure_defaults!
CoachingProduct.ensure_defaults!

now = Time.current
month_start = now.beginning_of_month.change(hour: 9)

instructor_a = User.find_by!(email: "instructor1@speakflow.kr")
instructor_b = User.find_by!(email: "instructor2@speakflow.kr")
student = User.find_or_create_by!(email: "settlement-demo@speakflow.kr") do |user|
  user.name = "정산 데모 학생"
  user.password = "password123"
  user.role = :student
end

category_a = Category.find_by!(name: "발표 스피치")
category_b = Category.find_by!(name: "면접 스피치")
coach_plan = MembershipPlan.find_by!(slug: "coach")
interview_product = CoachingProduct.find_by!(slug: "interview-intensive")

course_a = Course.find_or_initialize_by(title: "정산 데모 발표 코스")
course_a.assign_attributes(
  category: category_a,
  instructor: instructor_a,
  instructor_name: instructor_a.name,
  description: "월정액 정산 테스트용 발표 강의",
  enrollment_deadline: Date.current.end_of_month,
  start_date: Date.current.beginning_of_month,
  end_date: Date.current.end_of_month + 3.months
)
course_a.save!

course_b = Course.find_or_initialize_by(title: "정산 데모 면접 코스")
course_b.assign_attributes(
  category: category_b,
  instructor: instructor_b,
  instructor_name: instructor_b.name,
  description: "첨삭 및 월정액 정산 테스트용 면접 강의",
  enrollment_deadline: Date.current.end_of_month,
  start_date: Date.current.beginning_of_month,
  end_date: Date.current.end_of_month + 3.months
)
course_b.save!

[
  [course_a, 4, "정산 데모 발표 강의"],
  [course_b, 3, "정산 데모 면접 강의"]
].each do |course, count, prefix|
  count.times do |index|
    lecture = course.lectures.find_or_initialize_by(order_no: index + 1)
    lecture.assign_attributes(
      title: "#{prefix} #{index + 1}",
      video_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      duration: 1_200
    )
    lecture.save!
  end
end

subscription = student.subscriptions.find_or_initialize_by(
  membership_plan: coach_plan,
  started_at: month_start
)
subscription.assign_attributes(
  status: :active,
  current_period_end: month_start + 1.month,
  canceled_at: nil
)
subscription.save!

subscription_entry = student.coaching_credit_entries.find_or_initialize_by(source: subscription)
subscription_entry.assign_attributes(
  credits_amount: coach_plan.monthly_coaching_credits,
  remaining_credits: coach_plan.monthly_coaching_credits,
  expires_at: subscription.current_period_end,
  label: "#{coach_plan.name} 포함 첨삭 크레딧"
)
subscription_entry.save!

purchase = student.coaching_purchases.find_or_initialize_by(
  coaching_product: interview_product,
  paid_amount: interview_product.price,
  credits_amount: interview_product.credits_amount
)
purchase.assign_attributes(status: :completed)
purchase.save!

purchase_entry = student.coaching_credit_entries.find_or_initialize_by(source: purchase)
purchase_entry.assign_attributes(
  credits_amount: interview_product.credits_amount,
  remaining_credits: interview_product.credits_amount,
  label: "#{interview_product.name} 구매 크레딧"
)
purchase_entry.save!

watched_lectures = course_a.lectures.order(:order_no).to_a + course_b.lectures.order(:order_no).to_a
watched_lectures.each_with_index do |lecture, index|
  progress = Progress.find_or_initialize_by(user: student, lecture: lecture)
  progress.assign_attributes(
    watched: true,
    watched_at: month_start + (index + 1).days
  )
  progress.save!
end

request_specs = [
  {
    title: "정산 데모 발표 첨삭",
    course: course_a,
    lecture: course_a.lectures.order(:order_no).first,
    instructor: instructor_a,
    entry: subscription_entry,
    reviewed_at: month_start + 7.days,
    summary: "발표 도입부 호흡과 속도 조절이 좋고, 결론을 조금 더 또렷하게 마무리하면 좋습니다."
  },
  {
    title: "정산 데모 면접 첨삭 1차",
    course: course_b,
    lecture: course_b.lectures.order(:order_no).first,
    instructor: instructor_b,
    entry: purchase_entry,
    reviewed_at: month_start + 10.days,
    summary: "자기소개는 안정적이지만 꼬리질문에서 답변 전개가 조금 더 선명해질 필요가 있습니다."
  },
  {
    title: "정산 데모 면접 첨삭 2차",
    course: course_b,
    lecture: course_b.lectures.order(:order_no).second,
    instructor: instructor_b,
    entry: purchase_entry,
    reviewed_at: month_start + 13.days,
    summary: "2차 피드백에서는 답변 구조가 훨씬 좋아졌고, 말끝 처리만 다듬으면 더 좋겠습니다."
  }
]

request_specs.each_with_index do |spec, index|
  request = student.feedback_requests.find_or_initialize_by(title: spec[:title])
  request.assign_attributes(
    course: spec[:course],
    lecture: spec[:lecture],
    instructor: spec[:instructor],
    audio_reference: "/uploads/demo-audio-#{index + 1}.m4a",
    note: "정산 테스트용 첨삭 요청입니다.",
    status: :completed,
    reviewed_at: spec[:reviewed_at],
    response_summary: spec[:summary],
    response_timecodes: "00:15 도입부, 00:48 말끝 처리",
    used_credits: 1,
    credit_label: spec[:entry].source.is_a?(Subscription) ? "#{coach_plan.name} 포함 첨삭 사용" : "#{interview_product.name} 첨삭 사용",
    credit_source_preference: spec[:entry].source.is_a?(Subscription) ? :membership_first : :purchase_first,
    applied_credit_entry: spec[:entry]
  )
  request.save!

  CoachingCreditUsage.find_or_create_by!(
    user: student,
    feedback_request: request,
    coaching_credit_entry: spec[:entry]
  ) do |usage|
    usage.credits_amount = 1
  end

  student.coaching_credit_entries.find_or_create_by!(
    source: request,
    credits_amount: -1,
    remaining_credits: 0,
    label: request.credit_label
  )
end

[subscription_entry, purchase_entry].each do |entry|
  used_amount = entry.coaching_credit_usages.sum(:credits_amount)
  remaining = [entry.credits_amount - used_amount, 0].max
  entry.update!(remaining_credits: remaining)
end

puts "Settlement demo data ready."

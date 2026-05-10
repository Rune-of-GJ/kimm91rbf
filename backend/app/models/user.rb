class User < ApplicationRecord
  has_secure_password

  before_validation :normalize_auth_fields

  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :progresses, dependent: :destroy
  has_many :watched_lectures, through: :progresses, source: :lecture
  has_many :instructed_courses, class_name: "Course", foreign_key: :instructor_id, inverse_of: :instructor
  has_many :subscriptions, dependent: :destroy
  has_many :coaching_purchases, dependent: :destroy
  has_many :coaching_credit_entries, dependent: :destroy
  has_many :coaching_credit_usages, dependent: :destroy
  has_many :feedback_requests, dependent: :destroy
  has_many :review_feedback_requests, class_name: "FeedbackRequest", foreign_key: :instructor_id, inverse_of: :instructor, dependent: :nullify
  has_many :rehearsal_submissions, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, if: :password

  enum :role, { student: "student", instructor: "instructor", admin: "admin" }, default: :student

  def active_subscription
    subscriptions.active.current_first.detect(&:active_now?)
  end

  def membership_active?
    active_subscription.present?
  end

  def current_membership_plan
    active_subscription&.membership_plan
  end

  def coaching_credits_balance
    coaching_credit_entries.available_for_consumption.sum(:remaining_credits)
  end

  def current_month_rehearsal_usage(reference_time = Time.current)
    start_of_month = reference_time.beginning_of_month
    end_of_month = reference_time.end_of_month

    rehearsal_submissions.where(submitted_at: start_of_month..end_of_month).count
  end

  def remaining_rehearsal_count(reference_time = Time.current)
    plan = current_membership_plan
    return nil if plan.blank? || plan.monthly_rehearsal_limit >= 999

    [plan.monthly_rehearsal_limit - current_month_rehearsal_usage(reference_time), 0].max
  end

  def can_access_course?(course)
    membership_active? || enrollments.exists?(course_id: course.id)
  end

  def learning_courses
    if membership_active?
      Course.includes(:category, :lectures).order(created_at: :desc)
    else
      enrolled_courses.includes(:category, :lectures)
    end
  end

  private

  def normalize_auth_fields
    self.name = name.to_s.strip.presence
    self.email = email.to_s.strip.downcase.presence
  end
end

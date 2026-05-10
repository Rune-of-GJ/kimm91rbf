class FeedbackRequest < ApplicationRecord
  belongs_to :user
  belongs_to :course, optional: true
  belongs_to :lecture, optional: true
  belongs_to :instructor, class_name: "User", optional: true
  belongs_to :applied_credit_entry, class_name: "CoachingCreditEntry", optional: true
  has_many :coaching_credit_usages, dependent: :destroy

  enum :status, { queued: "queued", reviewing: "reviewing", completed: "completed" }, default: :queued
  enum :credit_source_preference, {
    membership_first: "membership_first",
    purchase_first: "purchase_first",
    oldest_first: "oldest_first"
  }, default: :membership_first

  validates :title, :audio_reference, :credit_label, presence: true
  validates :used_credits, numericality: { greater_than: 0 }
  validate :course_has_instructor_when_active
  validate :lecture_belongs_to_course
  validate :completed_request_has_feedback

  private

  def lecture_belongs_to_course
    return if lecture.blank? || course.blank?
    return if lecture.course_id == course_id

    errors.add(:lecture_id, "must belong to the selected course")
  end

  def course_has_instructor_when_active
    return if course.blank?
    return if instructor.present? || course.instructor.present?

    errors.add(:course_id, "must belong to a course with an assigned instructor")
  end

  def completed_request_has_feedback
    return unless completed?

    errors.add(:response_summary, "must be present when completing feedback") if response_summary.to_s.strip.blank?
    errors.add(:instructor, "must be assigned when completing feedback") if instructor.blank?
  end
end

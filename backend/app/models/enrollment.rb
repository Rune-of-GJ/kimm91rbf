class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :user_id, uniqueness: { scope: :course_id }
  validate :course_must_be_open_for_enrollment

  private

  def course_must_be_open_for_enrollment
    return if course.blank? || course.enrollment_open?

    errors.add(:course, "is closed for enrollment")
  end
end

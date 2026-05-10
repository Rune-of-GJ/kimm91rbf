class RehearsalSubmission < ApplicationRecord
  belongs_to :user
  belongs_to :subscription, optional: true
  belongs_to :course, optional: true
  belongs_to :lecture, optional: true

  validates :submitted_at, presence: true
  validates :source_label, presence: true
  validate :lecture_belongs_to_course

  private

  def lecture_belongs_to_course
    return if lecture.blank? || course.blank?
    return if lecture.course_id == course_id

    errors.add(:lecture_id, "must belong to the selected course")
  end
end

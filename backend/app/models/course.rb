class Course < ApplicationRecord
  belongs_to :category
  belongs_to :instructor, class_name: "User", optional: true

  has_many :lectures, -> { order(:order_no) }, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :feedback_requests, dependent: :nullify
  has_many :rehearsal_submissions, dependent: :nullify

  validates :title, :description, :instructor_name, presence: true
  validates :title, length: { minimum: 2, maximum: 120 }
  validate :validate_schedule_window

  def enrollment_open?(date = Date.current)
    enrollment_deadline.blank? || enrollment_deadline >= date
  end

  def available_on?(date = Date.current)
    starts_ok = start_date.blank? || start_date <= date
    ends_ok = end_date.blank? || end_date >= date
    starts_ok && ends_ok
  end

  private

  def validate_schedule_window
    if start_date.present? && end_date.present? && end_date < start_date
      errors.add(:end_date, "must be on or after the start date")
    end

    if enrollment_deadline.present? && end_date.present? && enrollment_deadline > end_date
      errors.add(:enrollment_deadline, "must be on or before the end date")
    end

    if max_access_days.present? && max_access_days <= 0
      errors.add(:max_access_days, "must be greater than 0")
    end
  end
end

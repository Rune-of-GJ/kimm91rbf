class User < ApplicationRecord
  before_validation :strip_auth_fields

  validates :name, presence: true
  validates :email, presence: true
  validates :password, presence: true, on: :create

  private

  def strip_auth_fields
    self.name = name.to_s.strip.presence
    self.email = email.to_s.strip.presence
  end
end
class User < ApplicationRecord
  has_secure_password
  before_validation :normalize_email

  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :progresses, dependent: :destroy
  has_many :watched_lectures, through: :progresses, source: :lecture
  has_many :instructed_courses, class_name: "Course", foreign_key: :instructor_id, inverse_of: :instructor

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, if: :password

  enum :role, { student: "student", instructor: "instructor", admin: "admin" }, default: :student

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end

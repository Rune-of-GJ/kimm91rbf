class Course < ApplicationRecord
  belongs_to :category
  belongs_to :instructor, class_name: "User", optional: true

  has_many :lectures, -> { order(:order_no) }, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  validates :title, :description, presence: true
  validates :instructor_name, presence: true
end

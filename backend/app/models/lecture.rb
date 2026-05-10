class Lecture < ApplicationRecord
  belongs_to :course

  has_many :progresses, dependent: :destroy
  has_many :feedback_requests, dependent: :nullify
  has_many :rehearsal_submissions, dependent: :nullify

  validates :title, :video_url, :order_no, presence: true
end

class Lecture < ApplicationRecord
  belongs_to :course

  has_many :progresses, dependent: :destroy

  validates :title, :video_url, :order_no, presence: true
end

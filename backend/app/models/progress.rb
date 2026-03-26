class Progress < ApplicationRecord
  belongs_to :user
  belongs_to :lecture

  validates :user_id, uniqueness: { scope: :lecture_id }
  validates :watched, inclusion: { in: [true, false] }
end

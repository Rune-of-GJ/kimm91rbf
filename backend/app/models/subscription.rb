class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :membership_plan
  has_many :rehearsal_submissions, dependent: :nullify

  enum :status, { active: "active", replaced: "replaced", canceled: "canceled" }, default: :active

  scope :current_first, -> { order(started_at: :desc, created_at: :desc) }

  validates :started_at, :current_period_end, presence: true

  def active_now?
    active? && current_period_end >= Time.current
  end
end

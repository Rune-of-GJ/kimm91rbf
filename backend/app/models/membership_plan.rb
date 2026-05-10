class MembershipPlan < ApplicationRecord
  DEFAULT_PLANS = [
    {
      slug: "lite",
      name: "Lite",
      tagline: "부담 없이 시작하는 입문형 월정액",
      monthly_price: 19_000,
      monthly_rehearsal_limit: 4,
      monthly_coaching_credits: 0,
      included_coaching_unit_price: 0,
      featured: false,
      position: 1
    },
    {
      slug: "pro",
      name: "Pro",
      tagline: "강의와 리허설을 꾸준히 이어가는 핵심 플랜",
      monthly_price: 39_000,
      monthly_rehearsal_limit: 12,
      monthly_coaching_credits: 0,
      included_coaching_unit_price: 0,
      featured: true,
      position: 2
    },
    {
      slug: "coach",
      name: "Coach",
      tagline: "월 2회 1:1 첨삭이 포함된 상위 플랜",
      monthly_price: 69_000,
      monthly_rehearsal_limit: 999,
      monthly_coaching_credits: 2,
      included_coaching_unit_price: 29_000,
      featured: false,
      position: 3
    }
  ].freeze

  has_many :subscriptions, dependent: :restrict_with_exception

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :monthly_price) }

  validates :name, :slug, :tagline, presence: true
  validates :slug, uniqueness: true
  validates :monthly_price, :monthly_rehearsal_limit, :monthly_coaching_credits, :included_coaching_unit_price,
    numericality: { greater_than_or_equal_to: 0 }

  def self.ensure_defaults!
    DEFAULT_PLANS.each do |attributes|
      plan = find_or_initialize_by(slug: attributes[:slug])
      plan.assign_attributes(attributes.merge(active: true))
      plan.save! if plan.changed?
    end
  end
end

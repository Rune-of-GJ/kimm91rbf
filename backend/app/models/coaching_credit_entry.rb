class CoachingCreditEntry < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true, optional: true
  has_many :coaching_credit_usages, dependent: :restrict_with_exception

  scope :available_for_consumption, lambda {
    where("remaining_credits > 0")
      .where("expires_at IS NULL OR expires_at > ?", Time.current)
      .order(:created_at, :id)
  }

  validates :label, presence: true
  validates :credits_amount, numericality: { other_than: 0 }
  validates :remaining_credits, numericality: { greater_than_or_equal_to: 0 }

  def subscription_source?
    source_type == "Subscription"
  end

  def purchase_source?
    source_type == "CoachingPurchase"
  end
end

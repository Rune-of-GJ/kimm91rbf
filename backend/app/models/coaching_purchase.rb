class CoachingPurchase < ApplicationRecord
  belongs_to :user
  belongs_to :coaching_product

  enum :status, { completed: "completed", refunded: "refunded" }, default: :completed

  validates :paid_amount, :credits_amount, numericality: { greater_than_or_equal_to: 0 }
end

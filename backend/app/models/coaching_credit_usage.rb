class CoachingCreditUsage < ApplicationRecord
  belongs_to :user
  belongs_to :feedback_request
  belongs_to :coaching_credit_entry

  validates :credits_amount, numericality: { greater_than: 0 }
end

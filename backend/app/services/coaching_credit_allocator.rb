class CoachingCreditAllocator
  class InsufficientCreditsError < StandardError; end

  PREFERENCES = %w[membership_first purchase_first oldest_first].freeze

  class AllocationPlan
    attr_reader :preference, :selections

    def initialize(preference:, selections:)
      @preference = preference
      @selections = selections
    end

    def primary_entry
      selections.first&.fetch(:entry)
    end

    def label
      return "첨삭 크레딧 사용" if selections.empty?
      return source_label(primary_entry) if selections.length == 1

      "혼합 첨삭 크레딧 사용"
    end

    def commit!(feedback_request:)
      selections.each do |selection|
        entry = CoachingCreditEntry.lock.find(selection[:entry].id)
        amount = selection[:amount]

        if entry.remaining_credits < amount
          raise InsufficientCreditsError, "Selected credit entry no longer has enough remaining credits."
        end

        entry.update!(remaining_credits: entry.remaining_credits - amount)

        CoachingCreditUsage.create!(
          user: feedback_request.user,
          feedback_request: feedback_request,
          coaching_credit_entry: entry,
          credits_amount: amount
        )
      end
    end

    private

    def source_label(entry)
      case entry.source
      when Subscription
        "#{entry.source.membership_plan.name} 포함 첨삭 사용"
      when CoachingPurchase
        "#{entry.source.coaching_product.name} 첨삭 사용"
      else
        entry.label.presence || "첨삭 크레딧 사용"
      end
    end
  end

  attr_reader :preference

  def initialize(user:, preference: nil)
    @user = user
    @preference = normalize_preference(preference)
  end

  def build_allocation(amount: 1)
    raise ArgumentError, "amount must be positive" unless amount.to_i.positive?

    remaining = amount
    selections = []

    prioritized_entries.each do |entry|
      break if remaining.zero?

      consumed_amount = [entry.remaining_credits, remaining].min
      next if consumed_amount.zero?

      selections << { entry: entry, amount: consumed_amount }
      remaining -= consumed_amount
    end

    raise InsufficientCreditsError, "Not enough coaching credits." if remaining.positive?

    AllocationPlan.new(preference: preference, selections: selections)
  end

  private

  attr_reader :user

  def prioritized_entries
    user.coaching_credit_entries
      .available_for_consumption
      .includes(:source)
      .to_a
      .sort_by do |entry|
        [
          priority_rank(entry),
          entry.expires_at || Time.zone.local(2999, 1, 1),
          entry.created_at,
          entry.id
        ]
      end
  end

  def priority_rank(entry)
    case preference
    when "purchase_first"
      entry.purchase_source? ? 0 : entry.subscription_source? ? 1 : 2
    when "membership_first"
      entry.subscription_source? ? 0 : entry.purchase_source? ? 1 : 2
    else
      0
    end
  end

  def normalize_preference(value)
    candidate = value.to_s
    PREFERENCES.include?(candidate) ? candidate : "membership_first"
  end
end

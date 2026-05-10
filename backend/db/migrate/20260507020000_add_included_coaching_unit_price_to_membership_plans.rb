class AddIncludedCoachingUnitPriceToMembershipPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :membership_plans, :included_coaching_unit_price, :integer, default: 0, null: false
  end
end

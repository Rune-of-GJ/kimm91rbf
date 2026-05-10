class CreateMembershipPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :membership_plans do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :tagline, null: false
      t.integer :monthly_price, null: false, default: 0
      t.integer :monthly_rehearsal_limit, null: false, default: 0
      t.integer :monthly_coaching_credits, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :featured, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :membership_plans, :slug, unique: true
    add_index :membership_plans, :active
  end
end

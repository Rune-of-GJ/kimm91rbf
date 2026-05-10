class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership_plan, null: false, foreign_key: true
      t.string :status, null: false, default: "active"
      t.datetime :started_at, null: false
      t.datetime :current_period_end, null: false
      t.datetime :canceled_at
      t.timestamps
    end

    add_index :subscriptions, :status
    add_index :subscriptions, [:user_id, :status]
  end
end

class CreateCoachingPurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :coaching_purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :coaching_product, null: false, foreign_key: true
      t.string :status, null: false, default: "completed"
      t.integer :paid_amount, null: false, default: 0
      t.integer :credits_amount, null: false, default: 0
      t.timestamps
    end

    add_index :coaching_purchases, :status
  end
end

class CreateCoachingCreditEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :coaching_credit_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :source, polymorphic: true, null: true
      t.integer :credits_amount, null: false
      t.string :label, null: false
      t.datetime :expires_at
      t.timestamps
    end

    add_index :coaching_credit_entries, [:user_id, :created_at]
  end
end

class AddCreditTrackingAndRehearsalSupport < ActiveRecord::Migration[8.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  class MigrationCreditEntry < ApplicationRecord
    self.table_name = "coaching_credit_entries"
  end

  def up
    add_column :coaching_credit_entries, :remaining_credits, :integer, default: 0, null: false
    add_column :feedback_requests, :credit_source_preference, :string, default: "membership_first", null: false
    add_reference :feedback_requests, :applied_credit_entry, foreign_key: { to_table: :coaching_credit_entries }

    create_table :coaching_credit_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feedback_request, null: false, foreign_key: true
      t.references :coaching_credit_entry, null: false, foreign_key: true
      t.integer :credits_amount, null: false, default: 1

      t.timestamps
    end

    add_index :coaching_credit_usages, [:feedback_request_id, :coaching_credit_entry_id], unique: true, name: "index_credit_usages_on_request_and_entry"

    create_table :rehearsal_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription, null: true, foreign_key: true
      t.references :course, null: true, foreign_key: true
      t.references :lecture, null: true, foreign_key: true
      t.datetime :submitted_at, null: false
      t.string :source_label, null: false, default: "manual"
      t.text :note

      t.timestamps
    end

    add_index :rehearsal_submissions, [:user_id, :submitted_at], name: "index_rehearsal_submissions_on_user_and_submitted_at"

    backfill_remaining_credits!
  end

  def down
    remove_index :rehearsal_submissions, name: "index_rehearsal_submissions_on_user_and_submitted_at"
    drop_table :rehearsal_submissions

    remove_index :coaching_credit_usages, name: "index_credit_usages_on_request_and_entry"
    drop_table :coaching_credit_usages

    remove_reference :feedback_requests, :applied_credit_entry, foreign_key: { to_table: :coaching_credit_entries }
    remove_column :feedback_requests, :credit_source_preference
    remove_column :coaching_credit_entries, :remaining_credits
  end

  private

  def backfill_remaining_credits!
    MigrationCreditEntry.reset_column_information

    MigrationUser.find_each do |user|
      entries = MigrationCreditEntry.where(user_id: user.id).order(:created_at, :id).to_a
      positive_entries = []

      entries.each do |entry|
        if entry.credits_amount.positive?
          entry.update_columns(remaining_credits: entry.credits_amount)
          positive_entries << entry
          next
        end

        entry.update_columns(remaining_credits: 0)
        credits_to_consume = entry.credits_amount.abs

        positive_entries.each do |source_entry|
          break if credits_to_consume.zero?
          next if source_entry.remaining_credits <= 0

          consumed_amount = [source_entry.remaining_credits, credits_to_consume].min
          source_entry.remaining_credits -= consumed_amount
          source_entry.update_columns(remaining_credits: source_entry.remaining_credits)
          credits_to_consume -= consumed_amount
        end
      end
    end
  end
end

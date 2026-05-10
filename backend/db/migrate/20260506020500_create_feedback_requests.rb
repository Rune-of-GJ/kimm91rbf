class CreateFeedbackRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :feedback_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: true, foreign_key: true
      t.references :lecture, null: true, foreign_key: true
      t.string :title, null: false
      t.text :note
      t.string :audio_reference, null: false
      t.string :status, null: false, default: "queued"
      t.integer :used_credits, null: false, default: 1
      t.string :credit_label, null: false
      t.timestamps
    end

    add_index :feedback_requests, :status
    add_index :feedback_requests, [:user_id, :created_at]
  end
end

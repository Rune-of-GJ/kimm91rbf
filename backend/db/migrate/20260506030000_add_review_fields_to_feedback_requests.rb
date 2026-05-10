class AddReviewFieldsToFeedbackRequests < ActiveRecord::Migration[8.1]
  def change
    add_reference :feedback_requests, :instructor, foreign_key: { to_table: :users }
    add_column :feedback_requests, :response_summary, :text
    add_column :feedback_requests, :response_timecodes, :text
    add_column :feedback_requests, :reviewed_at, :datetime
  end
end

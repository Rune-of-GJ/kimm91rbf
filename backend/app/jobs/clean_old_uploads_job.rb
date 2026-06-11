class CleanOldUploadsJob < ApplicationJob
  queue_as :default

  # Remove audio blobs with no attached feedback_request older than 90 days
  def perform
    cutoff = 90.days.ago
    orphaned = ActiveStorage::Blob
      .where("created_at < ?", cutoff)
      .where.not(
        id: ActiveStorage::Attachment.select(:blob_id)
      )

    count = orphaned.count
    orphaned.find_each(&:purge)
    Rails.logger.info "[CleanOldUploads] Purged #{count} orphaned blobs older than 90 days"
  end
end

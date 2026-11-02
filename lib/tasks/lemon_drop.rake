namespace :lemon_drop do
  # The live editor uploads a picked image before Save, so a pick that's
  # never saved leaves a file nothing uses. Run daily (Heroku Scheduler).
  desc 'Delete uploaded files that were never attached, a day after upload'
  task purge_unattached_uploads: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ...1.day.ago).find_each(&:purge)
  end
end
